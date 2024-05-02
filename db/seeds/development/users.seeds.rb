address = EthereumAddress.find_or_create_by(address: '0xdFf706db4A4819C41eAae10a407A146A2004f2E6')
if address.user.nil?
  address.create_user!(
    name: 'Kirill The Organizer',
    email: 'kirushik+organizer@gmail.com',
    kind: :organizer
  )
end
address.save!

address = EthereumAddress.find_or_create_by(address: '0xC0B3fE8427007278332F8128379856EfF0903ea3')
if address.user.nil?
  address.create_user!(
    name: 'Kirill The Judge',
    email: 'kirushik+judge@gmail.com',
    kind: :judge
  )
end
address.save!

address = EthereumAddress.find_or_create_by(address: '0x32cC2Eb4849571aA7A61676aEF60E96Da512c291')
if address.user.nil?
  address.create_user!(
    name: 'Kirill The Hacker',
    email: 'kirushik+hacker@gmail.com',
    kind: :hacker
  )
end
address.save!
