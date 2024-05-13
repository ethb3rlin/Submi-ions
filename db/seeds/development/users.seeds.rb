address = EthereumAddress.find_by(address: '0xdFf706db4A4819C41eAae10a407A146A2004f2E6')
if address.nil?
  user = User.create!(
    name: 'Kirill The Organizer',
    email: 'kirushik+organizer@gmail.com',
    kind: :organizer,
    approved_at: DateTime.now
  )
  address = EthereumAddress.create!(address: '0xdFf706db4A4819C41eAae10a407A146A2004f2E6', user: user)
end

address = EthereumAddress.find_by(address: '0xC0B3fE8427007278332F8128379856EfF0903ea3')
if address.nil?
  user = User.create!(
    name: 'Kirill The Judge',
    email: 'kirushik+judge@gmail.com',
    kind: :judge,
    approved_at: DateTime.now
  )
  address = EthereumAddress.create!(address: '0xC0B3fE8427007278332F8128379856EfF0903ea3', user: user)
end

address = EthereumAddress.find_by(address: '0x32cC2Eb4849571aA7A61676aEF60E96Da512c291')
if address.nil?
  user = User.create!(
    name: 'Kirill The Hacker',
    email: 'kirushik+hacker@gmail.com',
    kind: :hacker,
    approved_at: DateTime.now
  )
  address = EthereumAddress.create!(address: '0x32cC2Eb4849571aA7A61676aEF60E96Da512c291', user: user)
end
