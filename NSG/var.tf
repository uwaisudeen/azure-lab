variable "vnet" {
  type = map(object({
    address_space = string 
    subnet = list(object({
      name = string
      address_prefix = string
    }))
 } ))

  default = {
    "vnet1" = {
      address_space = "10.0.0.0/16"
      subnet = [{
        address_prefix = "10.0.0.0/24"
        name = "sub1"
      },
      {
        address_prefix = "10.0.1.0/24"
        name = "sub2"
      }]
    },
    "vnet2" ={
        address_space = "10.10.0.0/16"
        subnet = [{
          address_prefix = "10.10.0.0/24"
          name = "sub3"
        },
        {
          address_prefix = "10.10.1.0/24"
          name = "sub4"
        }
        ]
    }
  }
}