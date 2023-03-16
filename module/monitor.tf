resource "azurerm_monitor_metric_alert" "this" {
  count               = (try(var.mssql_databases, []) == []) ? 0 :length(local.monitor_metric_alert)
  name                = local.monitor_metric_alert[count.index].name
  resource_group_name = var.resource_group_name
  scopes              = [ for k, v in azurerm_mssql_database.this : tostring(v.id) ]
  enabled             = lookup(local.monitor_metric_alert[count.index], "enabled", true)
  auto_mitigate       = lookup(local.monitor_metric_alert[count.index], "auto_mitigate", true)
  description         = lookup(local.monitor_metric_alert[count.index], "description", null)
  frequency           = lookup(local.monitor_metric_alert[count.index], "frequency", "PT5M")
  severity            = lookup(local.monitor_metric_alert[count.index], "security", 3)
  target_resource_type = lookup(local.monitor_metric_alert[count.index], "target_resource_type", local.target_resource_type)
  target_resource_location = data.azurerm_resource_group.data.location
  window_size         = lookup(local.monitor_metric_alert[count.index], "window_size", "PT5M")

  criteria {
    metric_namespace = lookup(local.monitor_metric_alert[count.index], "metric_namespace", local.target_resource_type)
    metric_name      = local.monitor_metric_alert[count.index].metric_name
    aggregation      = local.monitor_metric_alert[count.index].aggregation
    operator         = local.monitor_metric_alert[count.index].operator
    threshold        = local.monitor_metric_alert[count.index].threshold
    skip_metric_validation = lookup(local.monitor_metric_alert[count.index], "skip_metric_validation", false)
        
    dynamic "dimension" {
      for_each = lookup(local.monitor_metric_alert[count.index], "dimension", [])
      content {
        name = dimension.value.name
        operator = dimension.value.operator
        values = dimension.value.values
      }
    }
  }
  
  dynamic "action" {
    for_each = lookup(local.monitor_metric_alert[count.index], "action", [])
    content {
      action_group_id = azurerm_monitor_action_group.this[0].id
      webhook_properties = lookup(action.value, "webhook_properties", null)
    }
  }

  depends_on = [
    azurerm_monitor_action_group.this,
    azurerm_mssql_database.this
  ]
}

resource "azurerm_monitor_action_group" "this" {
  count               = (try(var.mssql_databases, []) == []) ? 0 : length(local.monitor_action_group)
  name                = local.monitor_action_group[count.index].name
  resource_group_name = var.resource_group_name
  short_name          = local.monitor_action_group[count.index].short_name

  dynamic "email_receiver" {
    for_each = lookup(local.monitor_action_group[count.index], "email_receiver", [])
    content{
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }
}



