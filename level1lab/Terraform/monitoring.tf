resource "azurerm_monitor_metric_alert" "vm_cpu_alert" {
  name                = "vm-cpu-alert"
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name
  scopes              = [azurerm_linux_virtual_machine.vmlvl1.id]
  description         = "Alert when CPU usage exceeds 80%"

  window_size = "PT5M" # The time window for evaluating the metric
  frequency   = "PT1M" # How frequently the alert condition is evaluated

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group_lvl1.id
  }
}

resource "azurerm_monitor_action_group" "action_group_lvl1" {
  name                = "actionGroup_lablvl1"
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name
  short_name          = "agsal"

  email_receiver {
    name          = "admin"
    email_address = var.admin
  }
}


# Recovery Services Vault (corrected resource type)
resource "azurerm_recovery_services_vault" "recovery_vault_lvl1" {
  name                = "recovery-vault-lvl1"
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name
  location            = azurerm_resource_group.salomon-lablvl2.location
  sku                 = "Standard"
  soft_delete_enabled = true

  tags = {
    Environment = "Lab"
    Purpose     = "Backup"
  }
}

# Backup Policy for VM
resource "azurerm_backup_policy_vm" "pipeline_lablvl1" {
  name                = "pipeline-lablvl1"
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_vault_lvl1.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "00:00"
  }

  retention_daily {
    count = 30
  }

  retention_weekly {
    count    = 4
    weekdays = ["Sunday"]
  }
}

# Protected VM configuration
resource "azurerm_backup_protected_vm" "protected_vm_lvl1" {
  resource_group_name = azurerm_resource_group.salomon-lablvl2.name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_vault_lvl1.name
  source_vm_id        = azurerm_linux_virtual_machine.vmlvl1.id
  backup_policy_id    = azurerm_backup_policy_vm.pipeline_lablvl1.id
}