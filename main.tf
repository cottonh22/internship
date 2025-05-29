terraform {
  required_providers {
    hyperv = {
      source  = "tidalf/hyperv"
      version = ">= 1.0.0"
    }
  }
}

provider "hyperv" {
  user     = "terraform"
  password = "apple22"
   host     = "127.0.0.1"
  port     = 5985
  https    = false
  insecure = true
  timeout  = "30s"
}

# Create VHD first
resource "hyperv_vhd" "web_server_vhd" {
  path       = "C:\\Hyper-V\\Virtual Hard Disks\\Hannah_Ubuntu.vhdx"
  size       = 21474836480 # 20GB
  block_size = 33554432    # 32MB block size for dynamic VHD
  vhd_type   = "Dynamic"
}


# Create the VM
resource "hyperv_machine_instance" "default" {
  name                                    = "WebServer"
  generation                              = 2 # Changed to Gen 2 for better performance
  automatic_critical_error_action         = "Pause"
  automatic_critical_error_action_timeout = 30
  automatic_start_action                  = "StartIfRunning"
  automatic_start_delay                   = 0
  automatic_stop_action                   = "Save"
  checkpoint_type                         = "Production"
  dynamic_memory                          = false
  guest_controlled_cache_types            = false
  high_memory_mapped_io_space             = 536870912
  lock_on_disconnect                      = "Off"
  low_memory_mapped_io_space              = 134217728
  memory_maximum_bytes                    = 1099511627776 # 1GB max
  memory_minimum_bytes                    = 536870912     # 512MB min
  memory_startup_bytes                    = 536870912     # 512MB startup
  notes                                   = "Web Server VM created via Terraform"
  processor_count                         = 2 # Increased for better performance
  smart_paging_file_path                  = "C:\\ProgramData\\Microsoft\\Windows\\Hyper-V"
  snapshot_file_location                  = "C:\\ProgramData\\Microsoft\\Windows\\Hyper-V"
  static_memory                           = true
  state                                   = "Running"

  # Network adapter configuration
  network_adaptors {
    name                              = "Network Adapter"
    switch_name                       = "Default Switch"
    management_os                     = false
    is_legacy                         = false
    dynamic_mac_address               = true
    static_mac_address                = ""
    mac_address_spoofing              = "Off"
    dhcp_guard                        = "Off"
    router_guard                      = "Off"
    port_mirroring                    = "None"
    ieee_priority_tag                 = "Off"
    vmq_weight                        = 100
    iov_queue_pairs_requested         = 1
    iov_interrupt_moderation          = "Off"
    iov_weight                        = 100
    maximum_bandwidth                 = 0
    minimum_bandwidth_absolute        = 0
    minimum_bandwidth_weight          = 0
    mandatory_feature_id              = []
    resource_pool_name                = ""
    test_replica_pool_name            = ""
    test_replica_switch_name          = ""
    virtual_subnet_id                 = 0
    allow_teaming                     = "Off"
    not_monitored_in_cluster          = false
    storm_limit                       = 0
    dynamic_ip_address_limit          = 0
    device_naming                     = "Off"
    fix_speed_10g                     = "Off"
    packet_direct_num_procs           = 0
    packet_direct_moderation_count    = 0
    packet_direct_moderation_interval = 0
    vrss_enabled                      = true
    vmmq_enabled                      = false
    vmmq_queue_pairs                  = 16
  }

  # DVD drive for OS installation
  dvd_drives {
    controller_number   = 0
    controller_location = 1
    path                = "C:\\ISOs\\ubuntu-24.04.2-live-server-amd64.iso"
    resource_pool_name  = ""
  }

  # Hard disk drive
  hard_disk_drives {
    controller_type                 = "Scsi"
    controller_number               = 0
    controller_location             = 0
    path                            = hyperv_vhd.web_server_vhd.path
    disk_number                     = 4294967295
    resource_pool_name              = ""
    support_persistent_reservations = false
    maximum_iops                    = 0
    minimum_iops                    = 0
    qos_policy_id                   = "00000000-0000-0000-0000-000000000000"
    override_cache_attributes       = "Default"
  }

  depends_on = [
    hyperv_vhd.web_server_vhd,
  ]
}