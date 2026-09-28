terraform {
 backend "azurerm" {
  resource_group_name = "rg-bikeshare-tfstate"
  storage_account_name = "sabikeshareprj"
  container_name = "tfstate"
  key = "main.tfstate"
}
}
