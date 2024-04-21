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

end
