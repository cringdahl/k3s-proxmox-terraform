variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://<YOUR_PROXMOX_HOST>:8006/api2/json"
}

variable "proxmox_api_token_id" {
  description = "Proxmox API Token ID (format: user@realm!tokenname)"
  type        = string
  default     = "root@pam!terraform"
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = "YOUR_SSH_PUBLIC_KEY_HERE"
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "proxmox"
}

variable "template_id" {
  description = "VM template name for cloning"
  type        = string
  default     = "ubuntu-24.04-cloud-tpl"
}

variable "vm_id_start" {
  description = "Starting VM ID for created VMs"
  type        = number
  default     = 30000
}

variable "full_clone" {
  description = "Whether to create full clones (true) or linked clones (false)"
  type        = bool
  default     = true
}

variable "bios" {
  description = "BIOS type for VMs (valid types: 'bios', 'ovmf')"
  type        = string
  default     = "bios"
}

variable "storage_pool" {
  description = "Storage pool for VM disks"
  type        = string
  default     = "local-zfs"
}

variable "snippet_storage" {
  description = "Storage for cloud-init snippets"
  type        = string
  default     = "usb-storage-01"
}

variable "bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "subnet" {
  description = "Network subnet for VMs"
  type = string
  default = "172.16.22.0/23"
}

variable "control_plane_ip_offset" {
  description = "IP offset for control plane VMs in subnet"
  type        = number
  default     = 180
}

variable "worker_ip_offset" {
  description = "IP offset for worker VMs in subnet"
  type        = number
  default     = 185
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "192.168.100.1"
}

variable "searchdomain" {
  description = "DNS search domain"
  type        = string
  default     = "local"
}

# Control Plane Configuration
variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 1
}

variable "control_plane_cpu" {
  description = "CPU cores for control plane nodes"
  type        = number
  default     = 2
}

variable "control_plane_memory" {
  description = "Memory in MB for control plane nodes"
  type        = number
  default     = 4096
}

variable "control_plane_disk_size" {
  description = "Disk size for control plane nodes"
  type        = string
  default     = "10G"
}

variable "control_plane_ip_start" {
  description = "Starting IP for control plane nodes"
  type        = string
  default     = "192.168.100.180"
}

variable "control_plane_name_prefix" {
  description = "Prefix for control plane node names"
  type        = string
  default     = "k3s-cp"
}

# Worker Configuration
variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "worker_cpu" {
  description = "CPU cores for worker nodes"
  type        = number
  default     = 1
}

variable "worker_memory" {
  description = "Memory in MB for worker nodes"
  type        = number
  default     = 2048
}

variable "worker_disk_size" {
  description = "Disk size for worker nodes"
  type        = string
  default     = "10G"
}

variable "worker_ip_start" {
  description = "Starting IP for worker nodes"
  type        = string
  default     = "192.168.100.185"
}

variable "worker_name_prefix" {
  description = "Prefix for worker node names"
  type        = string
  default     = "k3s-worker"
}

# K3s Configuration
variable "k3s_version" {
  description = "K3s version to install"
  type        = string
  default     = "v1.34.1+k3s1"
}

variable "k3s_token" {
  description = "K3s cluster token (will be auto-generated if not provided)"
  type        = string
  default     = ""
  sensitive   = true
}