class Submission < ApplicationRecord
    def github_repo?
        url.present? && url.include?('github.com')
    end

    def user
        nil
    end
end
