logical_product_family  = "launch"
logical_product_service = "cogacct"
class_env               = "dev"
instance_env            = 0
instance_resource       = 0
location                = "eastus"

resource_names_map = {
  resource_group = {
    name       = "rg"
    max_length = 50
  }
  cognitive_account = {
    name       = "oai"
    max_length = 64
  }
}

kind     = "OpenAI"
sku_name = "S0"

public_network_access_enabled = true

tags = {
  Environment = "test"
  Terraform   = "true"
  Purpose     = "Terratest"
}
