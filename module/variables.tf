variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to create the Microsoft SQL Server"
}

variable "storage_accounta_name" {
  type        = string
  description = "Nome do Storage Account"
}

variable "container_name" {
  type        = string
  description = "Nome do Storage Container (existente)"
}

variable "mssql_server" {
  description = "Mapa de objetos com as variaveis relacionadas a criação e configuração de SQL Servers"
  type = map(object({
    name                                 = string
    version                              = string
    administrator_login                  = optional(string)
    administrator_login_password         = optional(string)
    connection_policy                    = optional(string)
    minimum_tls_version                  = optional(string)
    public_network_access_enabled        = optional(bool)
    outbound_network_restriction_enabled = optional(bool)
    primary_user_assigned_identity_id    = optional(string)

    identity = optional(list(object({
      type         = optional(string)
      identity_ids = optional(string)
    })))

    azuread_administrator = optional(list(object({
      login_username              = optional(string)
      object_id                   = optional(string)
      tenant_id                   = optional(string)
      azuread_authentication_only = optional(string)
    })))

    firewall_rules = list(object({
      name             = string
      server_id        = optional(string)
      start_ip_address = string
      end_ip_address   = string
    }))

    virtual_network_rule = list(object({
      name                                 = optional(string)
      server_id                            = optional(string)
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool)
    }))

    server_extended_auditing_policy = list(object({
      server_id                               = optional(string)
      enabled                                 = optional(bool)
      storage_endpoint                        = optional(string)
      retention_in_days                       = optional(number)
      storage_account_access_key              = optional(string)
      storage_account_access_key_is_secondary = optional(string)
      log_monitoring_enabled                  = optional(bool)
      storage_account_subscription_id         = optional(string)
    }))

    server_security_alert_policy = list(object({
      state                      = string
      disabled_alerts            = optional(list(string))
      email_account_admins       = optional(bool)
      email_addresses            = optional(list(string))
      retention_days             = optional(number)
      storage_endpoint           = optional(string)
      storage_account_access_key = optional(string)
    }))

    server_vulnerability_assessment = list(object({
      storage_container_path     = optional(string)
      storage_account_access_key = optional(string)
      storage_container_sas_key  = optional(string)
      recurring_scans = optional(list(object({
        enabled                   = optional(bool)
        email_subscription_admins = optional(bool)
        emails                    = optional(list(string))
      })))
    }))
  }))
}

variable "mssql_databases" {
  description = "Mapa de objetos com as variaveis relacionadas a criação e configuração de SQL Databases"
  type = map(object({
    name                                = string
    server_id                           = optional(string)
    auto_pause_delay_in_minutes         = optional(number)
    create_mode                         = optional(string)
    creation_source_database_id         = optional(string)
    collation                           = optional(string)
    elastic_pool_id                     = optional(string)
    geo_backup_enabled                  = optional(bool)
    maintenance_configuration_name      = optional(string)
    ledger_enabled                      = optional(bool)
    license_type                        = optional(string)
    max_size_gb                         = optional(number)
    min_capacity                        = optional(number)
    restore_point_in_time               = optional(string)
    recover_database_id                 = optional(string)
    restore_dropped_database_id         = optional(string)
    read_replica_count                  = optional(number)
    read_scale                          = optional(string)
    sample_name                         = optional(string)
    sku_name                            = optional(string)
    storage_account_type                = optional(string)
    transparent_data_encryption_enabled = optional(bool)
    zone_redundant                      = optional(string)

    import = list(object({
      storage_uri                  = optional(string)
      storage_key                  = optional(string)
      storage_key_type             = optional(string)
      administrator_login          = optional(string)
      administrator_login_password = optional(string)
      authentication_type          = optional(string)
      storage_account_id           = optional(string)
    }))

    threat_detection_policy = list(object({
      state                      = optional(string)
      disabled_alerts            = optional(list(string))
      email_account_admins       = optional(string)
      email_addresses            = optional(list(string))
      retention_days             = optional(number)
      storage_account_access_key = optional(string)
      storage_endpoint           = optional(string)
    }))

    long_term_retention_policy = list(object({
      weekly_retention  = optional(string)
      monthly_retention = optional(string)
      yearly_retention  = optional(string)
      week_of_year      = optional(number)
    }))

    short_term_retention_policy = list(object({
      retention_days           = optional(number)
      backup_interval_in_hours = optional(number)
    }))
   
    database_extended_auditing_policy = list(object({
      database_id                             = optional(string)
      enabled                                 = optional(bool)
      storage_endpoint                        = optional(string)
      retention_in_days                       = optional(number)
      storage_account_access_key              = optional(string)
      storage_account_access_key_is_secondary = optional(bool)
      log_monitoring_enabled                  = optional(bool)
    }))

    database_vulnerability_assessment_rule_baseline = list(object({
      database_name = optional(string)
      rule_id = string
      baseline_name = optional(string)
      baseline_result = optional(list(object({
        result = list(string)
      })))
    }))    
  }))
}

variable "tags" {
  type = map(any)
  default = {
    idorcamento = "ID000026",
    projeto     = "Hub",
    trilha      = "DEV"
  }
}