# This is a plain Ruby file which creates 10 different meaningful projects and stores them in the Submissions table
# We're interested only in title, description and url (pointing to Github) fields here

Submission.create_with(
  title: 'Ruby on  Rails',
  description: 'Ruby on Rails is a web-application framework that includes everything needed to create database-backed web applications according to the Model-View-Controller (MVC) pattern.'
).find_or_create_by!(
  url: 'https://github.com/rails/rails'
)

Submission.create_with(
  title: 'Diaspora',
  description: 'Diaspora is a privacy-aware, distributed, open source social network.'
).find_or_create_by!(
  url: 'https://github.com/diaspora/diaspora'
)

Submission.create_with(
  title: 'forem — For empowering community 🌱',
  description: 'Forem is open source software for building communities. Communities for your peers, customers, fanbases, families, friends, and any other time and space where people need to come together to be part of a collective. See our announcement post for a high-level overview of what Forem is.'
).find_or_create_by!(
  url: 'https://github.com/forem/forem'
)

Submission.create_with(
  title: 'spree',
  description: 'Spree is a complete open source e-commerce solution for Ruby on Rails.'
).find_or_create_by!(
  url: 'https://github.com/spree/spree'
)
