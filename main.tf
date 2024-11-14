terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://pve1.s1.lan:8006/api2/json"
  pm_tls_insecure = true
}

locals {
  cores       = 1
  memory      = 1024
  target_node = "pve1"
}

resource "proxmox_vm_qemu" "docker" {
  name                   = "test-vm"
  clone                  = "ubuntu-2204"
  target_node            = local.target_node
  cores                  = local.cores
  memory                 = local.memory
  agent                  = 1
  define_connection_info = true

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  scsihw  = "virtio-scsi-pci"
  hotplug = "disk"
  disks {
    sata {
      sata0 {
        disk {
          storage = "local-lvm"
          size    = "10G"
        }
      }
    }
    ide {
      ide3 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }
  boot = "order=sata0;"

  ipconfig0 = "ip=dhcp"
}

output "ip" {
  value = proxmox_vm_qemu.docker.ssh_host
}
