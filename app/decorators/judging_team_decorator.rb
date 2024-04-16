class JudgingTeamDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def track_name
    case object.track
    when "transact"
      "Freedom to Transact"
    when "infra"
      "Infrastructure"
    when "tooling"
      "Defensive Tooling"
    when "social"
      "Social Tech"
    end
  end
end
