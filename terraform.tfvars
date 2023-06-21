### Required variables of previously existing resources ###
resource_group_name = "resourcegrouptest"
storage_accounta_name = "storageaccounttest"
container_name      = "containertest"

### Azure SQL Server configuration ###
### See the variable.tf file in the module folder to evaluate all available variables and options ###
mssql_server = {
  server1 = {
    name                                 = "sqlservertest"
    version                              = "12.0"
    administrator_login                  = "sqltest3621"
    administrator_login_password         = "sql@test4983"
    public_network_access_enabled        = true
    outbound_network_restriction_enabled = true

    identity              = []
    azuread_administrator = []
    firewall_rules        = []
    virtual_network_rule  = []

    server_extended_auditing_policy = []
    server_security_alert_policy = []
    server_vulnerability_assessment = []
  }
}

### Azure SQL Databases configuration ###
### See the variable.tf file in the module folder to evaluate all available variables and options ###
mssql_databases = {
  db1 = {
    name = "dbtest"
    
    import = []
    threat_detection_policy = []
    long_term_retention_policy = []
    short_term_retention_policy = []

    database_extended_auditing_policy = []
    database_vulnerability_assessment_rule_baseline = []
  },
  db2 = {
    name = "dbtest2"
    
    import = []

    threat_detection_policy = []
    long_term_retention_policy = []
    short_term_retention_policy = []

    database_extended_auditing_policy = []
    database_vulnerability_assessment_rule_baseline = []
  }
}

