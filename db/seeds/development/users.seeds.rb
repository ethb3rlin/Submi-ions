address = EthereumAddress.find_or_create_by(address: '0xdFf706db4A4819C41eAae10a407A146A2004f2E6')
if address.user.nil?
  address.create_user!(
    email: 'kirushik@gmail.com',
    super_admin: true
  )
end
