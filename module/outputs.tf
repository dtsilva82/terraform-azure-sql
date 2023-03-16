#SQL SERVER
output "server_id" {
  value       = { for k, v in azurerm_mssql_server.this : k => v.id }
  description = "ID SQL server."
}

output "firewall_rule_id" {
  value       = { for k, v in azurerm_mssql_firewall_rule.this : k => v.id }
  description = "ID Firewall rules."
}

output "virtual_network_rule_id" {
  value       = { for k, v in azurerm_mssql_virtual_network_rule.this : k => v.id }
  description = "ID virtual network rules."
}

output "server_extended_auditing_policy_id" {
  value       = { for k, v in azurerm_mssql_server_extended_auditing_policy.this : k => v.id }
  description = "ID Extended Auditing Policy do SQL server."
}

#DATABASE
output "database_id" {
  value       = { for k, v in azurerm_mssql_database.this : k => v.id }
  description = "ID databases."
}

output "database_extended_auditing_policy_id" {
  value       = { for k, v in azurerm_mssql_database_extended_auditing_policy.this : k => v.id }
  description = "ID Extended Auditing Policy of the Database."
}

#Monitor Metric Alert
output "monitor_metric_alert_id" {
  value = { for k, v in azurerm_monitor_metric_alert.this : k => v.id }
  description = "ID monitor metric alerts."
}

#Monitor Action Group´
output "monitor_action_group_id" {
  value = { for k, v in azurerm_monitor_action_group.this : k => v.id }
  description = "ID monitor action group."
}