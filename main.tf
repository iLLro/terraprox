terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.111.100:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = "1qaz2wsx"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "example" {
  name        = "terraform-test"
  target_node = "proxmox-node"
#  vmid        = 100
  memory      = 1024
  cores       = 1
  sockets     = 1
  disk {
    size    = "10G"
    type    = "scsi"
    storage = "local-lvm"
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  os_type = "cloud-init"
  clone   = "deb-templ"
}  