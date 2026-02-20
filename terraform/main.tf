# Generate random token for K3s cluster
resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

locals {
  k3s_token = var.k3s_token != "" ? var.k3s_token : random_password.k3s_token.result
}

# Control Plane Nodes
resource "proxmox_vm_qemu" "k3s_control_plane" {
  count = var.control_plane_count

  name        = "${var.control_plane_name_prefix}-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = var.template_id
  full_clone  = var.full_clone
  vmid        = var.vm_id_start + count.index

  agent   = 1
  os_type = "cloud-init"
  memory  = var.control_plane_memory

  cpu {
    type    = "host"
    cores   = var.control_plane_cpu
    sockets = 1
  }
  scsihw   = "virtio-scsi-single"
  bios     = var.bios
  # bootdisk = "scsi0"

  onboot  = true
  startup = "order=1"

  disks {
    virtio {
      virtio0 {
        disk {
          storage = var.storage_pool
          size    = var.worker_disk_size
        }
      }
    }
    # CloudInit drive
    scsi {
      scsi0 {
        cloudinit {
          storage = var.storage_pool
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
  }

  # 172.16.22.0/23 as our example
  ipconfig0 = "ip=${cidrhost(var.subnet, var.control_plane_ip_offset + count.index)}/${substr(var.subnet, -2, 2)},gw=${cidrhost(var.subnet, 1)}"

  nameserver   = var.nameserver
  searchdomain = var.searchdomain

  ciuser     = "ubuntu"
  cipassword = "ubuntu"
  cicustom   = var.cicustom
  sshkeys    = var.ssh_public_key

  lifecycle {
    ignore_changes = [
      network,
      ciuser,
      sshkeys,
    ]
  }
}

# Worker Nodes
resource "proxmox_vm_qemu" "k3s_worker" {
  count = var.worker_count

  name        = "${var.worker_name_prefix}-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = var.template_id
  full_clone  = var.full_clone
  vmid        = var.vm_id_start + var.control_plane_count + count.index

  agent   = 1
  os_type = "cloud-init"
  memory  = var.worker_memory

  cpu {
    type    = "host"
    cores   = var.worker_cpu
    sockets = 1
  }
  scsihw   = "virtio-scsi-single"
  bios     = var.bios
  # bootdisk = "scsi0"

  onboot  = true
  startup = "order=2"

  disks {
    virtio {
      virtio0 {
        disk {
          storage = var.storage_pool
          size    = var.worker_disk_size
        }
      }
    }
    # CloudInit drive
    scsi {
      scsi0 {
        cloudinit {
          storage = var.storage_pool
        }
      }
    }
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.bridge
  }

  ipconfig0 = "ip=${cidrhost(var.subnet, var.worker_ip_offset + count.index)}/${substr(var.subnet, -2, 2)},gw=${cidrhost(var.subnet, 1)}"

  nameserver   = var.nameserver
  searchdomain = var.searchdomain

  ciuser     = "ubuntu"
  cipassword = "ubuntu"
  cicustom   = var.cicustom
  sshkeys    = var.ssh_public_key

  lifecycle {
    ignore_changes = [
      network,
      ciuser,
      sshkeys,
    ]
  }

  depends_on = [proxmox_vm_qemu.k3s_control_plane]
}