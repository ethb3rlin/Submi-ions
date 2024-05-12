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

  def zupass_url(callback_url)
    payload = {"type"=>"Get",
    "returnUrl"=>callback_url,
    "args"=>
     {"ticket"=>{"argumentType"=>"PCD", "pcdType"=>"eddsa-ticket-pcd", "userProvided"=>true, "validatorParams"=>{"eventIds"=>[], "productIds"=>[], "notFoundMessage"=>"No eligible PCDs found"}},
      "identity"=>{"argumentType"=>"PCD", "pcdType"=>"semaphore-identity-pcd", "userProvided"=>true},
      "validEventIds"=>{"argumentType"=>"StringArray", "value"=>["53edb3e7-6733-41e0-a9be-488877c5c572"], "userProvided"=>false},
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
      "externalNullifier"=>{"argumentType"=>"BigInt", "value"=>"286221548613905319765390676747549020842773565836071072789446643597948148432", "userProvided"=>false},
      "watermark"=>{"argumentType"=>"BigInt", "value"=>"393662727178615156857885255537022063054299486604806608471397216310022167464", "userProvided"=>false}},
    "pcdType"=>"zk-eddsa-event-ticket-pcd",
    "options"=>{"genericProveScreen"=>true, "title"=>"EthBerlin04 Ticket", "description"=>"Please confirm that you've been issued a valid EthBerlin04 ticket."},
    "postMessage"=>false}

    'https://zupass.org/#/prove?request=' + ERB::Util.url_encode(payload.to_json)
  end
end
