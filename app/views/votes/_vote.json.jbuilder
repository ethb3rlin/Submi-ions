json.extract! vote, :id, :mark, :user_id, :submission_id, :created_at, :updated_at
json.url vote_url(vote, format: :json)
