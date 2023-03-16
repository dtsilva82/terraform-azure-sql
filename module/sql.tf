resource "azurerm_mssql_server" "this" {
  for_each                             = var.mssql_server
  name                                 = each.value.name
  resource_group_name                  = var.resource_group_name
  location                             = data.azurerm_resource_group.data.location
  version                              = lookup(each.value, "version", "12.0")
  administrator_login                  = lookup(each.value, "administrator_login", null)
  administrator_login_password         = lookup(each.value, "administrator_login_password", null)
  connection_policy                    = lookup(each.value, "connection_policy", "Defaults")
  minimum_tls_version                  = lookup(each.value, "minimum_tls_version", "1.2")
  public_network_access_enabled        = lookup(each.value, "public_network_access_enabled", false)
  outbound_network_restriction_enabled = lookup(each.value, "outbound_network_restriction_enabled", false)
  primary_user_assigned_identity_id    = lookup(each.value, "primary_user_assigned_identity_id", null)

  dynamic "identity" {
    for_each = lookup(each.value, "identity", [])
    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  dynamic "azuread_administrator" {
    for_each = lookup(each.value, "azuread_administrator", [])
    content {
      login_username              = lookup(azuread_administrator.value, "login_username", null)
      object_id                   = lookup(azuread_administrator.value, "object_id", null)
      tenant_id                   = lookup(azuread_administrator.value, "tenant_id", null)
      azuread_authentication_only = lookup(azuread_administrator.value, "azuread_authentication_only", null)
    }
  }

  depends_on = [
    data.azurerm_resource_group.data
  ]

  tags = var.tags
}

resource "azurerm_mssql_firewall_rule" "this" {
  count            = length(local.firewall_rules)
  name             = local.firewall_rules[count.index].name
  server_id        = element(values(azurerm_mssql_server.this)[*].id, length(var.mssql_server))
  start_ip_address = local.firewall_rules[count.index].start_ip_address
  end_ip_address   = local.firewall_rules[count.index].end_ip_address

  depends_on = [
    azurerm_mssql_server.this
  ]
}

resource "azurerm_mssql_virtual_network_rule" "this" {
  count                                = length(local.virtual_network_rule)
  name                                 = local.virtual_network_rule[count.index].name
  server_id                            = element(azurerm_mssql_server.this[*].id, length(var.mssql_server))
  subnet_id                            = local.virtual_network_rule.subnet_id
  ignore_missing_vnet_service_endpoint = lookup(local.virtual_network_rule[count.index], "ignore_missing_vnet_service_endpoint", false)

  depends_on = [
    azurerm_mssql_server.this
  ]
}

resource "azurerm_mssql_server_extended_auditing_policy" "this" {
  count                                   = length(local.server_extended_auditing_policy)
  enabled                                 = lookup(local.server_extended_auditing_policy[count.index], "enabled", true)
  server_id                               = element(values(azurerm_mssql_server.this)[*].id, length(var.mssql_server))
  storage_endpoint                        = lookup(local.server_extended_auditing_policy[count.index], "storage_endpoint", data.azurerm_storage_account.data.primary_blob_endpoint)
  retention_in_days                       = lookup(local.server_extended_auditing_policy[count.index], "retention_in_days", 0)
  storage_account_access_key              = lookup(local.server_extended_auditing_policy[count.index], "storage_account_access_key", data.azurerm_storage_account.data.primary_access_key)
  storage_account_access_key_is_secondary = lookup(local.server_extended_auditing_policy[count.index], "storage_account_access_key_is_secondary", false)
  log_monitoring_enabled                  = lookup(local.server_extended_auditing_policy[count.index], "log_monitoring_enabled", true)
  storage_account_subscription_id         = lookup(local.server_extended_auditing_policy[count.index], "storage_account_subscription_id", null)

  depends_on = [
    data.azurerm_storage_account.data,
    azurerm_mssql_server.this
  ]
}

resource "azurerm_mssql_server_security_alert_policy" "this" {
  count                      = length(local.server_security_alert_policy)
  resource_group_name        = var.resource_group_name
  server_name                = element(values(azurerm_mssql_server.this)[*].name, length(var.mssql_server))
  state                      = local.server_security_alert_policy[count.index].state
  disabled_alerts            = lookup(local.server_security_alert_policy[count.index], "disabled_alerts", null)
  email_account_admins       = lookup(local.server_security_alert_policy[count.index], "email_account_admins", false)
  email_addresses            = lookup(local.server_security_alert_policy[count.index], "email_addresses", null)
  retention_days             = lookup(local.server_security_alert_policy[count.index], "retention_days", 0)
  storage_endpoint           = lookup(local.server_security_alert_policy[count.index], "storage_endpoint", data.azurerm_storage_account.data.primary_blob_endpoint)
  storage_account_access_key = lookup(local.server_security_alert_policy[count.index], "storage_account_access_key", data.azurerm_storage_account.data.primary_access_key)

  depends_on = [
    data.azurerm_storage_account.data,
    azurerm_mssql_server.this
  ]
}

resource "azurerm_mssql_server_vulnerability_assessment" "this" {
  count                           = length(local.server_vulnerability_assessment)
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.this[count.index].id
  storage_container_path          = "${data.azurerm_storage_account.data.primary_blob_endpoint}${data.azurerm_storage_container.data.name}/"
  storage_account_access_key      = lookup(local.server_vulnerability_assessment[count.index], "storage_account_access_key", data.azurerm_storage_account.data.primary_access_key)
  storage_container_sas_key       = lookup(local.server_vulnerability_assessment[count.index], "storage_container_sas_key", null)

  dynamic "recurring_scans" {
    for_each = lookup(local.server_vulnerability_assessment[count.index], "recurring_scans", [])
    content {
      enabled                   = lookup(recurring_scans.value, "enabled", false)
      email_subscription_admins = lookup(recurring_scans.value, "email_subscription_admins", false)
      emails                    = lookup(recurring_scans.value, "emails", null)
    }
  }

  depends_on = [
    azurerm_mssql_server_security_alert_policy.this,
    data.azurerm_storage_container.data
  ]

}

resource "azurerm_mssql_database" "this" {
  for_each                            = try(var.mssql_databases, [])
  name                                = each.value.name
  server_id                           = element(values(azurerm_mssql_server.this)[*].id, length(var.mssql_server))
  auto_pause_delay_in_minutes         = lookup(each.value, "auto_pause_delay_in_minutes", -1)
  create_mode                         = lookup(each.value, "create_mode", null)
  creation_source_database_id         = lookup(each.value, "create_mode", null) != null ? lookup(each.value, "create_source_database_id", null) : null
  collation                           = lookup(each.value, "collation", null)
  elastic_pool_id                     = lookup(each.value, "elastic_pool_id", null)
  geo_backup_enabled                  = lookup(each.value, "geo_backup_enabled", true)
  maintenance_configuration_name      = lookup(each.value, "elastic_pool_id", null) == null ? lookup(each.value, "maintenance_configuration_name", "SQL_Default") : null
  ledger_enabled                      = lookup(each.value, "ledger_enabled", false)
  license_type                        = lookup(each.value, "license_type", null)
  max_size_gb                         = (lookup(each.value, "create mode", null) == "Secondary" || lookup(each.value, "create mode", null) == "OnlineSecondary") ? null : lookup(each.value, "max_size_gb", null)
  min_capacity                        = lookup(each.value, "min_capacity", null)
  restore_point_in_time               = lookup(each.value, "create mode", null) == "PointInTimeRestore" ? lookup(each.value, "restore_point_in_time", null) : null
  recover_database_id                 = lookup(each.value, "create mode", null) == "Recovery" ? lookup(each.value, "recover_database_id", null) : null
  restore_dropped_database_id         = lookup(each.value, "create mode", null) == "Restore" ? lookup(each.value, "restore_dropped_database_id", null) : null
  read_replica_count                  = lookup(each.value, "read_replica_count", 0)
  read_scale                          = lookup(each.value, "read_scale", "Disabled")
  sample_name                         = lookup(each.value, "sample_name", null)
  sku_name                            = lookup(each.value, "sku", null)
  storage_account_type                = lookup(each.value, "storage_account_type", "Geo")
  transparent_data_encryption_enabled = lookup(each.value, "transparent_data_encryption_enabled", true)
  zone_redundant                      = lookup(each.value, "zone_redundant", false)

  dynamic "import" {
    for_each = lookup(each.value, "import", [])
    content {
      storage_uri                  = lookup(import.value, "storage_uri", data.azurerm_storage_account.data.primary_blob_endpoint)
      storage_key                  = lookup(import.value, "storage_key", data.azurerm_storage_account.data.primary_access_key)
      storage_key_type             = import.value.storage_key_type
      administrator_login          = element(values(azurerm_mssql_server.this)[*].administrator_login, length(var.mssql_server))
      administrator_login_password = element(values(azurerm_mssql_server.this)[*].administrator_login_password, length(var.mssql_server))
      authentication_type          = import.value.authentication_type
      storage_account_id           = lookup(import.value, "storage_account_id", null)
    }
  }

  dynamic "threat_detection_policy" {
    for_each = lookup(each.value, "threat_detection_policy", [])
    content {
      state                      = lookup(threat_detection_policy.value, "state", null)
      disabled_alerts            = lookup(threat_detection_policy.value, "disabled_alerts", null)
      email_account_admins       = lookup(threat_detection_policy.value, "email_account_admins", null)
      email_addresses            = lookup(threat_detection_policy.value, "email_addresses", null)
      retention_days             = lookup(threat_detection_policy.value, "retention_days", null)
      storage_account_access_key = lookup(threat_detection_policy.value, "state", null) == "Enable" ? lookup(threat_detection_policy.value, "storage_account_access_key", data.azurerm_storage_account.data.primary_access_key) : null
      storage_endpoint           = lookup(threat_detection_policy.value, "state", null) == "Enable" ? lookup(threat_detection_policy.value, "storage_endpoint", data.azurerm_storage_account.data.primary_blob_endpoint) : null
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = lookup(each.value, "long_term_retention_policy", [])
    content {
      weekly_retention  = lookup(long_term_retention_policy.value, "weekly_retention", null)
      monthly_retention = lookup(long_term_retention_policy.value, "monthly_retention", null)
      yearly_retention  = lookup(long_term_retention_policy.value, "yearly_retention", null)
      week_of_year      = lookup(long_term_retention_policy.value, "week_of_year", null)
    }
  }  

  dynamic "short_term_retention_policy" {
    for_each = lookup(each.value, "short_term_retention_policy", [])
    content {
      retention_days           = lookup(short_term_retention_policy.value, "retention_days", null)
      backup_interval_in_hours = lookup(short_term_retention_policy.value, "backup_interval_in_hours", null)
    }  
  }

  tags = var.tags

  depends_on = [
    azurerm_mssql_server.this
  ]
}

resource "azurerm_mssql_database_extended_auditing_policy" "this" {
  count                                   = length(local.database_extended_auditing_policy)
  database_id                             = element(values(azurerm_mssql_database.this)[*].id, count.index)
  enabled                                 = lookup(local.database_extended_auditing_policy[count.index], "enabled", true)
  storage_endpoint                        = lookup(local.database_extended_auditing_policy[count.index], "storage_endpoint", data.azurerm_storage_account.data.primary_blob_endpoint)
  retention_in_days                       = lookup(local.database_extended_auditing_policy[count.index], "retention_in_days", 0)
  storage_account_access_key              = lookup(local.database_extended_auditing_policy[count.index], "storage_account_access_key", data.azurerm_storage_account.data.primary_access_key)
  storage_account_access_key_is_secondary = lookup(local.database_extended_auditing_policy[count.index], "storage_account_access_key_is_secondary", false)
  log_monitoring_enabled                  = lookup(local.database_extended_auditing_policy[count.index], "log_monitoring_enabled", true)
  

  depends_on = [
    data.azurerm_storage_account.data,
    azurerm_mssql_database.this
  ]
}

resource "azurerm_mssql_database_vulnerability_assessment_rule_baseline" "this" {
  count = length(local.database_vulnerability_assessment_rule_baseline)
  server_vulnerability_assessment_id = azurerm_mssql_server_vulnerability_assessment.this[0].id
  database_name                      = element(values(azurerm_mssql_database.this)[*].name, count.index)
  rule_id                            = local.database_vulnerability_assessment_rule_baseline[count.index].rule_id
  baseline_name                      = lookup(local.database_vulnerability_assessment_rule_baseline[count.index], "baseline_name", "default")
 
  dynamic "baseline_result" {
    for_each = local.database_vulnerability_assessment_rule_baseline[count.index].baseline_result
    content {
      result = baseline_result.value.result
    }
  }
}

