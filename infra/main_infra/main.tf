resource "azurerm_resource_group" "main" {
name = "rg-bikeshare-dev"
location = "eastus"
}


resource "azurerm_storage_account" "main" {
	resource_group_name = azurerm_resource_group.main.name
	location = azurerm_resource_group.main.location
	name = "sabikesharefleetproject"
	is_hns_enabled = true
	account_tier = "Standard"
	account_replication_type= "LRS"
}


resource "azurerm_storage_container" "bronze" {
	name = "bronze"
	storage_account_name = azurerm_storage_account.main.name
	container_access_type = "private"
}


resource "azurerm_storage_container" "silver" {
	name = "silver"
	storage_account_name = azurerm_storage_account.main.name
	container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
	name = "gold"
	storage_account_name = azurerm_storage_account.main.name
	container_access_type = "private"
}

resource "azurerm_key_vault" "main" {
  name                       = "kv-bikeshare-dev"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled    = false
}

data "azurerm_client_config" "current" {}