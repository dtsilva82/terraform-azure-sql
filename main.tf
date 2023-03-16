### Resource Group ###
module "sql" {
  source = "./module"

  resource_group_name   = var.resource_group_name
  storage_accounta_name = var.storage_accounta_name
  container_name        = var.container_name

  mssql_server = var.mssql_server
  mssql_databases = var.mssql_databases
  tags         = var.tags

}
