# == Schema Information
#
# Table name: judgements
#
#  id                :bigint           not null, primary key
#  no_show           :boolean          default(FALSE), not null
#  time              :time
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  concept_vote_id   :bigint
#  judging_team_id   :bigint           not null
#  product_vote_id   :bigint
#  submission_id     :bigint           not null
#  technical_vote_id :bigint
#
# Indexes
#
#  index_judgements_on_concept_vote_id    (concept_vote_id)
#  index_judgements_on_judging_team_id    (judging_team_id)
#  index_judgements_on_product_vote_id    (product_vote_id)
#  index_judgements_on_submission_id      (submission_id)
#  index_judgements_on_technical_vote_id  (technical_vote_id)
#  index_judgements_on_time               (time)
#
# Foreign Keys
#
#  fk_rails_...  (concept_vote_id => votes.id) ON DELETE => nullify
#  fk_rails_...  (judging_team_id => judging_teams.id)
#  fk_rails_...  (product_vote_id => votes.id) ON DELETE => nullify
#  fk_rails_...  (submission_id => submissions.id)
#  fk_rails_...  (technical_vote_id => votes.id) ON DELETE => nullify
#
class Judgement < ApplicationRecord
  include ActionView::RecordIdentifier # We need this for dom_id to work
  include Rails.application.routes.url_helpers # Add route helpers

  belongs_to :judging_team
  belongs_to :submission

  belongs_to :technical_vote, class_name: "Vote", dependent: :destroy, optional: true
  belongs_to :product_vote, class_name: "Vote", dependent: :destroy, optional: true
  belongs_to :concept_vote, class_name: "Vote", dependent: :destroy, optional: true

  after_save_commit :broadcast_new_judgement

  # Don't include no-show judgements in the default scope
  default_scope { where(no_show: false) }
  scope :with_no_show, -> { unscope(where: :no_show) }

  scope :empty, -> { where(technical_vote_id: nil, product_vote_id: nil, concept_vote_id: nil) }
  scope :incomplete, -> {
      # Querying Judgements where any vote (technical, product, concept) is incomplete or NULL
      incomplete_votes_query = Vote.where(completed: false)

      judgements_with_incomplete_technical_votes = Judgement.left_outer_joins(:technical_vote).merge(incomplete_votes_query).or(Judgement.where(technical_vote: nil))
      judgements_with_incomplete_product_votes = Judgement.left_outer_joins(:product_vote).merge(incomplete_votes_query).or(Judgement.where(product_vote: nil))
      judgements_with_incomplete_concept_votes = Judgement.left_outer_joins(:concept_vote).merge(incomplete_votes_query).or(Judgement.where(concept_vote: nil))

      # Combining the queries using UNION; inelegant, but easy to follow
      from("(#{judgements_with_incomplete_technical_votes.to_sql} UNION #{judgements_with_incomplete_product_votes.to_sql} UNION #{judgements_with_incomplete_concept_votes.to_sql}) AS judgements")
    }
  scope :completed, -> {
      # All of the votes are marked as completed
      completed_votes_query = Vote.where(completed: true)

      judgements_with_completed_technical_votes = Judgement.joins(:technical_vote).merge(completed_votes_query)
      judgements_with_completed_product_votes = Judgement.joins(:product_vote).merge(completed_votes_query)
      judgements_with_completed_concept_votes = Judgement.joins(:concept_vote).merge(completed_votes_query)

      # Combining the queries using INTERSECT; inelegant, but easy to follow
      from("(#{judgements_with_completed_technical_votes.to_sql} INTERSECT #{judgements_with_completed_product_votes.to_sql} INTERSECT #{judgements_with_completed_concept_votes.to_sql}) AS judgements")
  }

  JUDGING_DURATION = 10.minutes

  def just_time
    self[:time]&.strftime("%H:%M")
  end

  def complete_for(user)
    Vote.transaction do
      technical_vote.update!(completed: true) if technical_vote.user == user
      product_vote.update!(completed: true) if product_vote.user == user
      concept_vote.update!(completed: true) if concept_vote.user == user
      update!(no_show: false)
    end

    if completed?
      broadcast_append_to judging_team, :judgement_redirects,
        html: "<script>window.location = '#{next_location}';</script>".html_safe,
        target: 'body'
    end
  end

  def completed?
    technical_vote&.completed && product_vote&.completed && concept_vote&.completed
  end

  def mark_as_no_show!
    update!(no_show: true)
    broadcast_append_to judging_team, :judgement_redirects,
      html: "<script>window.location = '#{next_location}';</script>".html_safe,
      target: 'body'
  end

  def initialize_votes!
    transaction do
      create_technical_vote!(user: judging_team.technical_judge, mark: 0) unless technical_vote.present?
      create_product_vote!(user: judging_team.product_judge, mark: 0) unless product_vote.present?
      create_concept_vote!(user: judging_team.concept_judge, mark: 0) unless concept_vote.present?
      save! if self.changed?
    end
  end

  def total_score
    (technical_vote&.mark||0) + (product_vote&.mark||0) + (concept_vote&.mark||0)
  end

  def self.schedule_missing!
    Judgement.transaction do
      JudgingTeam.all.pluck(:id).each do |team_id|
        latest_time = Judgement.where(judging_team_id: team_id).where.not(time: nil).order(time: :desc).limit(1).pluck(:time).last

        scheduled_time = if latest_time.present?
          latest_time + JUDGING_DURATION
        else
          # FIXME: This parsing uses local date and timezone, while "natural" deserializing from Postgres
          # uses UTC and 01 Jan 2000 as the date. This is a workaround for that.
          Time.parse(Setting.judging_start_time).change(year: 2000, month: 1, day: 1, offset: Time.zone.formatted_offset)
        end

        breaks = JudgingBreak.order(:begins).pluck(:begins, :ends)

        Judgement.where(judging_team_id: team_id, time: nil).order(:created_at).each do |judgement|
          # If our scheduled time is within one of the breaks, we need to schedule it at the end of the break
          breaks.each do |begin_time, end_time|
            logger.debug "Scheduled time: #{scheduled_time}, begin_time: #{begin_time}, end_time: #{end_time}"

            if scheduled_time.between?(begin_time, end_time)
              scheduled_time = end_time
              break
            end
          end

          judgement.update!(time: scheduled_time.strftime("%H:%M"))
          scheduled_time = scheduled_time + JUDGING_DURATION
        end
      end
    end
  end

  private
  def broadcast_new_judgement
    broadcast_replace_to judging_team, :judgements, locals: {judgement: self}, target: dom_id(submission)
    broadcast_replace_to 'submissions', target: dom_id(submission), partial: 'submissions/tr', locals: { submission: submission }
  end

  def next_location
    if judging_team.current_judgement.present?
      judgement_path(judging_team.current_judgement)
    else
      judgements_path
    end
  end
end
