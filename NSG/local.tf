locals {
     rules_csv = csvdecode(file("rules.csv"))
  vnet_subnet = {
    for vnet_key, vnet_val in azurerm_virtual_network.vnet :
    vnet_key => [for subnet in vnet_val.subnet : subnet.name]
  }
  vnet_subid = {
    for vnet_key, vnet_val in azurerm_virtual_network.vnet :
    vnet_key => [for subnet in vnet_val.subnet : subnet.id]
  }
  subnet_name = flatten(values(local.vnet_subnet))

  nsg_count = length(flatten(values(local.vnet_subid)))
  nsg_name = [for i in range (local.nsg_count) : "subnet-nsg${i+1}"]
}
