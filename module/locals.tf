locals {
  ### Azure Monitor Metric Alert Configuration ###
  ### Metrics and email sending changes must be performed here ###
  target_resource_type = "Microsoft.Sql/servers/databases"

  ## Metrics and alerts variable configuration ##
  monitor_metric_alert = [
  {
    name = "SQL-CPU percent"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
    dimension = []

    action = [{
      webhook_properties = {
        from = "terraform"
      }
    }]
  },
  {
    name = "SQL-Memory percent"
    metric_name      = "memory_usage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
    dimension = []

    action = [{
      webhook_properties = {
        from = "terraform"
      }
    }]
  },
  {
    name = "SQL-Storage percent"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
    dimension = []
 
    action = [{
      webhook_properties = {
        from = "terraform"
      }
    }]
  },
  ]
  
  ### Variable for sending alerts by e-mail Configuration ###
  monitor_action_group = [{
    name = "CriticalAlertsAction"
    short_name = "p0action"
    email_receiver = [{
      name                    = "sendtoadmin"
      email_address           = "email.example@example.com"
      use_common_alert_schema = true      
    }]
  }]

  ### Do not touch! Unless you know what you're doing... ###
  ### mssql_server locals ###
  firewall_rules = flatten([
    for key, value in var.mssql_server : [
      for index, val in value.firewall_rules : {
        name             = val.name
        server_id        = val.server_id
        start_ip_address = val.start_ip_address
        end_ip_address   = val.end_ip_address
      }
    ]
  ])

  virtual_network_rule = flatten([
    for key, value in var.mssql_server : [
      for index, val in value.virtual_network_rule : {
        name                                 = val.name
        server_id                            = val.server_id
        subnet_id                            = val.subnet_id
        ignore_missing_vnet_service_endpoint = val.ignore_missing_vnet_service_endpoint
      }
    ]
  ])

  server_extended_auditing_policy = flatten([
    for key, value in var.mssql_server : [
      for index, val in value.server_extended_auditing_policy : {
        server_id                               = val.server_id
        enabled                                 = val.enabled
        storage_endpoint                        = val.storage_endpoint
        retention_in_days                       = val.retention_in_days
        storage_account_access_key              = val.storage_account_access_key
        storage_account_access_key_is_secondary = val.storage_account_access_key_is_secondary
        log_monitoring_enabled                  = val.log_monitoring_enabled
        storage_account_subscription_id         = val.storage_account_subscription_id
      }
    ]
  ])

  server_security_alert_policy = flatten([
    for key, value in var.mssql_server : [
      for index, val in value.server_security_alert_policy : {
        state                      = val.state
        disabled_alerts            = val.disabled_alerts
        email_account_admins       = val.email_account_admins
        email_addresses            = val.email_addresses
        retention_days             = val.retention_days
        storage_endpoint           = val.storage_endpoint
        storage_account_access_key = val.storage_account_access_key
      }
    ]
  ])

  server_vulnerability_assessment = flatten([
    for key, value in var.mssql_server : [
      for index, val in value.server_vulnerability_assessment : {
        storage_container_path     = val.storage_container_path
        storage_account_access_key = val.storage_account_access_key
        storage_container_sas_key  = val.storage_container_sas_key
        recurring_scans = [for k, v in val.recurring_scans : {
          enabled                   = v.enabled
          email_subscription_admins = v.email_subscription_admins
          emails                    = v.emails
        }]
      }
    ]
  ])

  ### mssql_databases locals ###
  database_extended_auditing_policy = flatten([
    for key, value in var.mssql_databases : [
      for index, val in value.database_extended_auditing_policy : {
        database_id                             = val.database_id
        enabled                                 = val.enabled
        storage_endpoint                        = val.storage_endpoint
        retention_in_days                       = val.retention_in_days
        storage_account_access_key              = val.storage_account_access_key
        storage_account_access_key_is_secondary = val.storage_account_access_key_is_secondary
        log_monitoring_enabled                  = val.log_monitoring_enabled
      }
    ]
  ])

  database_vulnerability_assessment_rule_baseline = flatten([
    for key, value in var.mssql_databases : [
      for index, val in value.database_vulnerability_assessment_rule_baseline : {
        database_name = val.database_name
        rule_id = val.rule_id
        baseline_name = val.baseline_name
        baseline_result = [for k, v in val.baseline_result : {
          result = v.result
      }]
    }]
  ])
}