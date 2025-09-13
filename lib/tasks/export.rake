namespace :export do
  desc "Export all HackingTeams and Submissions as markdown files, in a format which Zola static site generator can use"
  task to_zola: :environment do
    require 'fileutils'
    require 'yaml'

    output_dir = Rails.root.join('zola_export')
    FileUtils.rm_rf(output_dir) if Dir.exist?(output_dir)
    FileUtils.mkdir_p(output_dir)

    teams_dir = output_dir.join('teams')
    FileUtils.mkdir_p(teams_dir)

    submissions_dir = output_dir.join('submissions')
    FileUtils.mkdir_p(submissions_dir)

    # We're matching our existing routes: /teams/:id and /submissions/:id
    # We link the pages accordingly in the front matter
    # We're also using Zola taxonomies for tracks and excellence_award_tracks

    HackingTeam.includes(:submissions).find_each do |team|
      File.write(teams_dir.join("#{team.id}.md"), <<~MARKDOWN)
        +++
        title = "#{team.name}"
        +++
        # #{team.name}


        #{team.agenda}


        ### Submissions
        #{ team.submissions.map { |s| "- [#{s.title}](@/submissions/#{s.id}.md)" }.join("\n") }
      MARKDOWN

      team.submissions.find_each do |submission|
        File.write(submissions_dir.join("#{submission.id}.md"), <<~MARKDOWN)
          +++
          title = "#{submission.title}"
          track = "#{submission.track}"
          excellence_award_track = "#{submission.excellence_award_track}" # Can be empty
          team = "/teams/#{team.id}"
          +++

          # #{submission.title}

          ### Track: #{submission.track}
          #{ submission.excellence_award_track.present? ? "#### Excellence Award Track: #{submission.excellence_award_track}" : "" }

          ### Team: [#{team.name}](@/teams/#{team.id}.md)

          #{submission.description}

          #### Links
          - [Repository](#{submission.repo_url})
          #{ submission.pitchdeck_url.present? ? "- [Pitch Deck](#{submission.pitchdeck_url})" : "" }
        MARKDOWN
      end
    end
  end
end
