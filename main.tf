# Temporary change to make Git detect file change
terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.2.1"
    }
  }
}

provider "hyperv" {
}

resource "hyperv_machine" "ubuntu_vm" {
  name       = "Ubuntu-Terraform-VM"
  generation = 2
  cpus       = 2
  memory     = 2048
  secure_boot = false
  notes      = "Ubuntu VM deployed by Terraform"

  disk {
    path = "C:\\Hyper-V\\Virtual Hard Disks\\Ubuntu-Terraform-VM.vhdx"
    size = 30
  }

  network_adapter {
    name        = "Network Adapter"
    switch_name = "ExternalSwitch"  
  }

  dvd_drive {
    path = "C:\ISOs\ubuntu-24.04.2-live-server-amd64.iso" 
  }
  automatic_start_action = "Nothing"
  automatic_stop_action  = "Save"
  wait_for_ip = false
  state       = "Running"
}

output "vm_id" {
  value = hyperv_machine.ubuntu_vm.id
}

output "vm_network_adapters" {
  value = hyperv_machine.ubuntu_vm.network_adapter
}
