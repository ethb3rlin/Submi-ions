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
      # submissions should be a valid array in TOML in the following format:
      # submissions = [ {url = "/submissions/388", title = "DisrUptIng eThBeRlIn tHrOuGh aGgrEsSivE nOn-cOmPliaNcE ⚡️"} ]
      File.write(teams_dir.join("#{team.id}.md"), <<~MARKDOWN)
        +++
        title = "#{team.name}"

        [extra]
        name = "#{team.name}"
        submissions = [ #{ team.submissions.map { |s|
          "{ url = \"/submissions/#{s.id}\", title = \"#{s.title.gsub('"', '\"')}\" }"
        }.join(", ") } ]
        +++

        #{team.agenda}
      MARKDOWN

      team.submissions.find_each do |submission|
        File.write(submissions_dir.join("#{submission.id}.md"), <<~MARKDOWN)
          +++
          title = "#{submission.title}"

          [extra]

          track = "#{submission.track}"
          excellence_award_track = "#{submission.excellence_award_track}" # Can be empty
          team_name = "#{team.name}"
          team_link = "/teams/#{team.id}"
          repo_url = "#{submission.repo_url}"
          pitchdeck_url = "#{submission.pitchdeck_url}"
          +++

          #{submission.description}
        MARKDOWN
      end
    end
  end
end
