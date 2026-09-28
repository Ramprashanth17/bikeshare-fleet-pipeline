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
