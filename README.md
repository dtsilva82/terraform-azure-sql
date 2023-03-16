<!-- BEGIN_TF_DOCS -->
## About the module

Azure SQL, SQL Databases and Azure Monitor Metrics Alert (only criteria, with email sending) creation module.

Automatically created alarm metrics: cpu percent, memory usage percent, and storage percent.

## Scope and settings
terrarorm.tfvars

Creation of a SQL server, several databases (automatically associated with the SQL server), vulnerability assessment and auditing policy.

locals.tf

Automatic generation of basic metrics for all databases created, in addition to forwarding emails when the conditions of an alert are met.

## How to use

After applying the desired configuration in terraform.tfvars and locals.tf (Azure Monitor alert and group), in the root folder of the project, apply the commands below:

terraform init
terraform plan
terraform apply

## Requirements

Have Resource group, Storage Account and Storage Container already created

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_action_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_metric_alert.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_mssql_database.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_database_extended_auditing_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_extended_auditing_policy) | resource |
| [azurerm_mssql_database_vulnerability_assessment_rule_baseline.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database_vulnerability_assessment_rule_baseline) | resource |
| [azurerm_mssql_firewall_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_firewall_rule) | resource |
| [azurerm_mssql_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [azurerm_mssql_server_security_alert_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_security_alert_policy) | resource |
| [azurerm_mssql_server_vulnerability_assessment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_vulnerability_assessment) | resource |
| [azurerm_mssql_virtual_network_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_network_rule) | resource |
| [azurerm_resource_group.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_storage_container.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Nome do Storage Container (existente) | `string` | n/a | yes |
| <a name="input_mssql_databases"></a> [mssql\_databases](#input\_mssql\_databases) | Mapa de objetos com as variaveis relacionadas a criação e configuração de SQL Databases | <pre>map(object({<br>    name                                = string<br>    server_id                           = optional(string)<br>    auto_pause_delay_in_minutes         = optional(number)<br>    create_mode                         = optional(string)<br>    creation_source_database_id         = optional(string)<br>    collation                           = optional(string)<br>    elastic_pool_id                     = optional(string)<br>    geo_backup_enabled                  = optional(bool)<br>    maintenance_configuration_name      = optional(string)<br>    ledger_enabled                      = optional(bool)<br>    license_type                        = optional(string)<br>    max_size_gb                         = optional(number)<br>    min_capacity                        = optional(number)<br>    restore_point_in_time               = optional(string)<br>    recover_database_id                 = optional(string)<br>    restore_dropped_database_id         = optional(string)<br>    read_replica_count                  = optional(number)<br>    read_scale                          = optional(string)<br>    sample_name                         = optional(string)<br>    sku_name                            = optional(string)<br>    storage_account_type                = optional(string)<br>    transparent_data_encryption_enabled = optional(bool)<br>    zone_redundant                      = optional(string)<br><br>    import = list(object({<br>      storage_uri                  = optional(string)<br>      storage_key                  = optional(string)<br>      storage_key_type             = optional(string)<br>      administrator_login          = optional(string)<br>      administrator_login_password = optional(string)<br>      authentication_type          = optional(string)<br>      storage_account_id           = optional(string)<br>    }))<br><br>    threat_detection_policy = list(object({<br>      state                      = optional(string)<br>      disabled_alerts            = optional(list(string))<br>      email_account_admins       = optional(string)<br>      email_addresses            = optional(list(string))<br>      retention_days             = optional(number)<br>      storage_account_access_key = optional(string)<br>      storage_endpoint           = optional(string)<br>    }))<br><br>    weekly_retention  = string<br>    monthly_retention = string<br>    yearly_retention  = string<br>    week_of_year      = number<br><br>    retention_days           = number<br>    backup_interval_in_hours = number<br>   <br>    database_extended_auditing_policy = list(object({<br>      database_id                             = optional(string)<br>      enabled                                 = optional(bool)<br>      storage_endpoint                        = optional(string)<br>      retention_in_days                       = optional(number)<br>      storage_account_access_key              = optional(string)<br>      storage_account_access_key_is_secondary = optional(bool)<br>      log_monitoring_enabled                  = optional(bool)<br>    }))<br><br>    database_vulnerability_assessment_rule_baseline = list(object({<br>      database_name = optional(string)<br>      rule_id = string<br>      baseline_name = optional(string)<br>      baseline_result = optional(list(object({<br>        result = list(string)<br>      })))<br>    }))    <br>  }))</pre> | n/a | yes |
| <a name="input_mssql_server"></a> [mssql\_server](#input\_mssql\_server) | Mapa de objetos com as variaveis relacionadas a criação e configuração de SQL Servers | <pre>map(object({<br>    name                                 = string<br>    version                              = string<br>    administrator_login                  = optional(string)<br>    administrator_login_password         = optional(string)<br>    connection_policy                    = optional(string)<br>    minimum_tls_version                  = optional(string)<br>    public_network_access_enabled        = optional(bool)<br>    outbound_network_restriction_enabled = optional(bool)<br>    primary_user_assigned_identity_id    = optional(string)<br><br>    identity = optional(list(object({<br>      type         = optional(string)<br>      identity_ids = optional(string)<br>    })))<br><br>    azuread_administrator = optional(list(object({<br>      login_username              = optional(string)<br>      object_id                   = optional(string)<br>      tenant_id                   = optional(string)<br>      azuread_authentication_only = optional(string)<br>    })))<br><br>    firewall_rules = list(object({<br>      name             = string<br>      server_id        = optional(string)<br>      start_ip_address = string<br>      end_ip_address   = string<br>    }))<br><br>    virtual_network_rule = list(object({<br>      name                                 = optional(string)<br>      server_id                            = optional(string)<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool)<br>    }))<br><br>    server_extended_auditing_policy = list(object({<br>      server_id                               = optional(string)<br>      enabled                                 = optional(bool)<br>      storage_endpoint                        = optional(string)<br>      retention_in_days                       = optional(number)<br>      storage_account_access_key              = optional(string)<br>      storage_account_access_key_is_secondary = optional(string)<br>      log_monitoring_enabled                  = optional(bool)<br>      storage_account_subscription_id         = optional(string)<br>    }))<br><br>      server_security_alert_policy = list(object({<br>      state                      = string<br>      disabled_alerts            = optional(list(string))<br>      email_account_admins       = optional(bool)<br>      email_addresses            = optional(list(string))<br>      retention_days             = optional(number)<br>      storage_endpoint           = optional(string)<br>      storage_account_access_key = optional(string)<br>    }))<br><br>    server_vulnerability_assessment = list(object({<br>      storage_container_path     = optional(string)<br>      storage_account_access_key = optional(string)<br>      storage_container_sas_key  = optional(string)<br>      recurring_scans = optional(list(object({<br>        enabled                   = optional(bool)<br>        email_subscription_admins = optional(bool)<br>        emails                    = optional(list(string))<br>      })))<br>    }))<br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the Microsoft SQL Server | `string` | n/a | yes |
| <a name="input_sa_name"></a> [sa\_name](#input\_sa\_name) | Nome do Storage Account | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | <pre>{<br>  "idorcamento": "ID000026",<br>  "projeto": "Hub",<br>  "trilha": "DEV"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_extended_auditing_policy_id"></a> [database\_extended\_auditing\_policy\_id](#output\_database\_extended\_auditing\_policy\_id) | ID Extended Auditing Policy do Database. |
| <a name="output_database_id"></a> [database\_id](#output\_database\_id) | ID dos databases. |
| <a name="output_firewall_rule_id"></a> [firewall\_rule\_id](#output\_firewall\_rule\_id) | ID da Firewall rule. |
| <a name="output_server_extended_auditing_policy_id"></a> [server\_extended\_auditing\_policy\_id](#output\_server\_extended\_auditing\_policy\_id) | ID Extended Auditing Policy do SQL server. |
| <a name="output_server_id"></a> [server\_id](#output\_server\_id) | ID do SQL server. |
| <a name="output_virtual_network_rule_id"></a> [virtual\_network\_rule\_id](#output\_virtual\_network\_rule\_id) | ID da virtual network rule. |
<!-- END_TF_DOCS -->