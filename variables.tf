variable "resource_group_name" {}

variable "storage_accounta_name" {}

variable "container_name" {}

variable "mssql_server" {}

variable "mssql_databases" {}

variable "tags" {
  type = map(any)
  default = {
    idorcamento = "ID000026",
    projeto     = "Hub",
    trilha      = "DEV"
  }
}