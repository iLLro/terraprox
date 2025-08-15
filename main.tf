terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.81.0"
    }
  }
}


provider "proxmox" {
  endpoint = "https://192.168.111.100:8006/"
  insecure = true
  username = "root@pam"
  password = "1qaz2wsx"
}

#creez template ubuntu

resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = "ubuntu-template"
  node_name = "pve00"

  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  efi_disk {
    datastore_id = "pve-nfs"
    type         = "4m"
  }

  disk {
    datastore_id = "pve-nfs"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "pve00"
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve00"
  source_file {
    path = "${path.module}/user-data.yaml"
  }
}


# Creez vm-uri din template vm-1 pana la vm-x

variable "vm_count" {
  type        = number
  default     = 4
  description = "Number of VMs to create from the template"
}

resource "proxmox_virtual_environment_vm" "ubuntu_vms" {
  count     = var.vm_count
  name      = "vm-${count.index + 1}"
  node_name = "pve00"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}

/**
#creez vm-uri dupa o lista de nume
variable "vm_names" {
  type    = list(string)
  default = ["vm1-tf", "vm2-tf"]
  }

resource "proxmox_virtual_environment_vm" "ubuntu_vms" {
  for_each  = toset(var.vm_names)

  name      = each.value
  node_name = "pve00"

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.id
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
  }
}

**/