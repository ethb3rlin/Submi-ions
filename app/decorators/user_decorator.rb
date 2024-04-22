class UserDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def current_user?
    object == h.current_user
  end

  def readable_name
    if object.name.present?
      object.name
    else
      # At least one address is guaranteed to exist, otherwise the user wouldn't be able to sign in
      helpers.content_tag :code do
        object.ethereum_addresses.first.address
      end
    end
  end

  def navbar_class
    if object.organizer?
      'is-primary'
    elsif object.judge?
      'is-dark'
    else
      'is-light'
    end
  end

  def role_icon
    if object == h.current_user
      'person-standing'
    elsif object.organizer?
      'shield'
    elsif object.judge?
      'scale'
    else
      'user'
    end
  end

  def rendered_ethereum_addresses
    object.ethereum_addresses.map do |ea|
      helpers.content_tag :code, ea.address, class: 'is-size-7'
    end.join(', ').html_safe
  end
end
