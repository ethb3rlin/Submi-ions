class GenerateRandomTeamJob < Que::Job
  def run
    team = HackingTeam.create!(name: Faker::Team.name + ' ' + Faker::Alphanumeric.alpha(number:3), agenda: Faker::Markdown.sandwich)
    5.times do
      user = User.create!(name: Faker::Name.name, email: Faker::Internet.email)
      user.approve_as!(User.first)
      JoinApplication.create!(user: user, hacking_team: team, state: :approved)
      user.ethereum_addresses.create!(address: Faker::Blockchain::Ethereum.address)
    end

    team.submissions.create!(title: Faker::Company.catch_phrase, description: Faker::Company.bs, url: Faker::Internet.url, track: Submission.tracks.keys.sample)
  end
end
