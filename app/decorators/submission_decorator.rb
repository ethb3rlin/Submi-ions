class SubmissionDecorator < Draper::Decorator
  delegate_all

  def repo_icon_class
    return unless object.repo_url.present?

    if object.repo_url.include?('github.com')
      'github'
    elsif object.repo_url.include?('gitlab')
      'gitlab'
    else
      'file-code'
    end
  end

  def formatted_description
    h.format_markdown(object.description).html_safe
  end

  def github_repo_card
    return unless object.github_repo?

    # Extract username and repo from the URL
    url_parts = object.repo_url.split('/')
    username = url_parts[3]
    repo = url_parts[4]

    # Build the HTML for the GitHub repository card
    h.content_tag(:a, href: object.repo_url, class: 'github-card', 'aria-label': 'Repository on GitHub') do
      h.content_tag(:img, '', src: "https://gh-card.dev/repos/#{username}/#{repo}.svg", alt: '')
      # TODO replace me with a self-hosted or client-side solution, possibly https://lab.lepture.com/github-cards
    end
  end

end
