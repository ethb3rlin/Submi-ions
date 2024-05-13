require 'commonmarker'
require 'digest'

module ApplicationHelper
  include Rails.application.routes.url_helpers # Add route helpers

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

  ETHBERLIN_ZUPASS_ID = '53edb3e7-6733-41e0-a9be-488877c5c572'.freeze

  def watermark_digest(user)
    Digest::SHA256.hexdigest("EthBerlin04 user #{user.id}").unpack('C*').join('')
  end

  def zupass_url(user)
    watermark = watermark_digest(user)
    callback_url = user_verify_zupass_credentials_url(user_id: user.id)

    payload = {"type"=>"Get",
    "returnUrl"=>callback_url,
    "args"=>
     {"ticket"=>{"argumentType"=>"PCD", "pcdType"=>"eddsa-ticket-pcd", "userProvided"=>true, "validatorParams"=>{"eventIds"=>[ETHBERLIN_ZUPASS_ID], "productIds"=>[], "notFoundMessage"=>"Can't find your EthBerlin04 ticket."}},
      "identity"=>{"argumentType"=>"PCD", "pcdType"=>"semaphore-identity-pcd", "userProvided"=>true},
      "validEventIds"=>{"argumentType"=>"StringArray", "value"=>[ETHBERLIN_ZUPASS_ID], "userProvided"=>false},
      "fieldsToReveal"=>
       {"argumentType"=>"ToggleList",
        "value"=>
         {"revealTicketId"=>true,
          "revealEventId"=>false,
          "revealProductId"=>false,
          "revealTimestampConsumed"=>false,
          "revealTimestampSigned"=>false,
          "revealAttendeeSemaphoreId"=>false,
          "revealIsConsumed"=>false,
          "revealIsRevoked"=>true,
          "revealAttendeeEmail"=>false,
          "revealAttendeeName"=>false},
        "userProvided"=>false},
      "externalNullifier"=>{},
      "watermark"=>{"argumentType"=>"BigInt", "value"=>watermark, "userProvided"=>false}},
    "pcdType"=>"zk-eddsa-event-ticket-pcd",
    "options"=>{"genericProveScreen"=>true, "title"=>"EthBerlin04 Ticket", "description"=>"Please confirm that you've been issued a valid EthBerlin04 ticket."},
    "postMessage"=>true}

    'https://zupass.org/#/prove?request=' + ERB::Util.url_encode(payload.to_json)
  end
end
