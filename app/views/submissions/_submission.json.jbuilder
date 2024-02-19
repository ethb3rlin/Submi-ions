json.extract! submission, :id, :title, :description, :url, :created_at, :updated_at
json.url submission_url(submission, format: :json)
