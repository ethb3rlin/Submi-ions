after 'development:users' do
  team = HackingTeam.create_with(
    agenda: 'To hack the planet'
  ).find_or_create_by!(
    name: 'Hackers United'
  )
  User.hacker.first.hacking_teams << team

  HackingTeam.create_with(
    agenda: 'To hack the universe and beyond'
  ).find_or_create_by!(
    name: 'Hackers United 2'
  )
end
