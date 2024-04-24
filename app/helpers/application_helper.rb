module ApplicationHelper
  def active_class(path)
    if request.path.starts_with? path
      return 'is-active is-selected'
    else
      return ''
    end
  end
end
