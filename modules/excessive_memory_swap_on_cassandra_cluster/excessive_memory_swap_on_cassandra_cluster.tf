resource "shoreline_notebook" "excessive_memory_swap_on_cassandra_cluster" {
  name       = "excessive_memory_swap_on_cassandra_cluster"
  data       = file("${path.module}/data/excessive_memory_swap_on_cassandra_cluster.json")
  depends_on = [shoreline_action.invoke_get_vm_dirty_ratios,shoreline_action.invoke_upgrade_server_memory,shoreline_action.invoke_update_cassandra_config,shoreline_action.invoke_swappiness_script]
}

resource "shoreline_file" "get_vm_dirty_ratios" {
  name             = "get_vm_dirty_ratios"
  input_file       = "${path.module}/data/get_vm_dirty_ratios.sh"
  md5              = filemd5("${path.module}/data/get_vm_dirty_ratios.sh")
  description      = "Check the value of dirty_ratio and dirty_background_ratio"
  destination_path = "/agent/scripts/get_vm_dirty_ratios.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "upgrade_server_memory" {
  name             = "upgrade_server_memory"
  input_file       = "${path.module}/data/upgrade_server_memory.sh"
  md5              = filemd5("${path.module}/data/upgrade_server_memory.sh")
  description      = "Upgrade the physical memory of the servers in the Cassandra cluster to provide more space for data to reside in memory rather than needing to swap to disk."
  destination_path = "/agent/scripts/upgrade_server_memory.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_cassandra_config" {
  name             = "update_cassandra_config"
  input_file       = "${path.module}/data/update_cassandra_config.sh"
  md5              = filemd5("${path.module}/data/update_cassandra_config.sh")
  description      = "Tune the Cassandra configuration to reduce memory consumption, for example, by limiting the number of concurrent queries or reducing the size of data kept in memory."
  destination_path = "/agent/scripts/update_cassandra_config.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "swappiness_script" {
  name             = "swappiness_script"
  input_file       = "${path.module}/data/swappiness_script.sh"
  md5              = filemd5("${path.module}/data/swappiness_script.sh")
  description      = "Adjust the swapping configuration of the operating system to prevent it from swapping too aggressively."
  destination_path = "/agent/scripts/swappiness_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_vm_dirty_ratios" {
  name        = "invoke_get_vm_dirty_ratios"
  description = "Check the value of dirty_ratio and dirty_background_ratio"
  command     = "`chmod +x /agent/scripts/get_vm_dirty_ratios.sh && /agent/scripts/get_vm_dirty_ratios.sh`"
  params      = []
  file_deps   = ["get_vm_dirty_ratios"]
  enabled     = true
  depends_on  = [shoreline_file.get_vm_dirty_ratios]
}

resource "shoreline_action" "invoke_upgrade_server_memory" {
  name        = "invoke_upgrade_server_memory"
  description = "Upgrade the physical memory of the servers in the Cassandra cluster to provide more space for data to reside in memory rather than needing to swap to disk."
  command     = "`chmod +x /agent/scripts/upgrade_server_memory.sh && /agent/scripts/upgrade_server_memory.sh`"
  params      = ["SERVER_IP","MEMORY_SIZE","NEW_MEMORY"]
  file_deps   = ["upgrade_server_memory"]
  enabled     = true
  depends_on  = [shoreline_file.upgrade_server_memory]
}

resource "shoreline_action" "invoke_update_cassandra_config" {
  name        = "invoke_update_cassandra_config"
  description = "Tune the Cassandra configuration to reduce memory consumption, for example, by limiting the number of concurrent queries or reducing the size of data kept in memory."
  command     = "`chmod +x /agent/scripts/update_cassandra_config.sh && /agent/scripts/update_cassandra_config.sh`"
  params      = ["MAX_QUERIES","MAX_MEMORY"]
  file_deps   = ["update_cassandra_config"]
  enabled     = true
  depends_on  = [shoreline_file.update_cassandra_config]
}

resource "shoreline_action" "invoke_swappiness_script" {
  name        = "invoke_swappiness_script"
  description = "Adjust the swapping configuration of the operating system to prevent it from swapping too aggressively."
  command     = "`chmod +x /agent/scripts/swappiness_script.sh && /agent/scripts/swappiness_script.sh`"
  params      = ["DESIRED_SWAPPINESS_VALUE"]
  file_deps   = ["swappiness_script"]
  enabled     = true
  depends_on  = [shoreline_file.swappiness_script]
}

