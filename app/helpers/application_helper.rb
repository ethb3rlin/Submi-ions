require 'commonmarker'

module ApplicationHelper
  def active_class(path)
    if request.path.starts_with? path
      return 'is-active is-selected'
    else
      return ''
    end
  end

  def format_markdown(source)
    return '' if source.blank?

    content = Commonmarker.to_html(source, options:{ parse: { smart: true }, render: { escape: true }})
    sanitized_content = sanitize(content, tags: %w(h1 h2 h3 h4 h5 h6 p a ul ol li table tr td th input img blockquote br pre span hr em strong del), attributes: %w(href src type style checked disabled))
    sanitized_content.gsub(/<a href="http[^"]*"/) { |match| match.gsub('<a href="', '<a target="_blank" href="') }
  end
end
