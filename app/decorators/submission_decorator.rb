class SubmissionDecorator < Draper::Decorator
  delegate_all

  def github_repo_card
    return unless object.github_repo?

    # Extract username and repo from the URL
    url_parts = object.url.split('/')
    username = url_parts[3]
    repo = url_parts[4]

    # Build the HTML for the GitHub repository card
    h.content_tag(:a, href: object.url, class: 'github-card', 'aria-label': 'Repository on GitHub') do
      h.content_tag(:img, '', src: "https://gh-card.dev/repos/#{username}/#{repo}.svg", alt: '')
      # TODO replace me with a self-hosted or client-side solution, possibly https://lab.lepture.com/github-cards
    end
  end

end
