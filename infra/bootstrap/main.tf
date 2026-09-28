terraform {
	required_providers {
		azurerm = {
			source = "hashicorp/azurerm"
			version = "~>3.90"
			}
		}
}

provider "azurerm" {
	features {}
}

resource "azurerm_resource_group" "main" {
name = "rg-bikeshare-tfstate"
location = "eastus"
}

resource "azurerm_storage_account" "main"{
	resource_group_name = azurerm_resource_group.main.name
	name = "sabikeshareprj"
	location = azurerm_resource_group.main.location
	account_tier="Standard"
	account_replication_type="LRS"
}

resource "azurerm_storage_container" "tfstate" {
	name = "tfstate"
	storage_account_name = azurerm_storage_account.main.name
	container_access_type="private"
}