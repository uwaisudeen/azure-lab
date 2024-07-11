
//Creating resource group

resource "azurerm_resource_group" "rg" {
  name = "nsg"
  location = "centralindia"
}

//Creating two virtual network

resource "azurerm_virtual_network" "vnet" {
  for_each = var.vnet
  name = each.key
  location = azurerm_resource_group.rg.location
  address_space = [ each.value.address_space ]
  resource_group_name = azurerm_resource_group.rg.name

  //creating two subnets

  dynamic "subnet" {
    for_each = each.value.subnet
    content {
      name = each.value.subnet[subnet.key].name
      address_prefix = each.value.subnet[subnet.key].address_prefix
    }
  }
  depends_on = [ azurerm_resource_group.rg ]
}

//Creating NSG

resource "azurerm_network_security_group" "nsg" {
  for_each =  toset(local.nsg_name)
  name = each.key
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dynamic "security_rule" {
    for_each = {for rule in local.rules_csv : rule.name => rule }
    content {
      name                       = security_rule.value.name 
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_address_prefix
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
  depends_on = [ azurerm_virtual_network.vnet ]
}

//Associate the NSG for respective Subnets

resource "azurerm_subnet_network_security_group_association" "nsg_associate" {
  for_each ={ for idx, subnet_id in flatten([for vnet in local.vnet_subid : vnet]) : idx => subnet_id }
  network_security_group_id =  azurerm_network_security_group.nsg[local.nsg_name[each.key]].id
  subnet_id = each.value
   depends_on = [ azurerm_network_security_group.nsg , azurerm_virtual_network.vnet]
}
