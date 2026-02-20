# Write control_plane and worker names and IPs to Ansible inventory file

resource "local_file" "ansible_inventory" {
  content = yamlencode({
    all = {
      vars = {
        ansible_user = "ubuntu"
        ansible_ssh_common_args = "-o StrictHostKeyChecking=no"
        k3s_version = var.k3s_version
      }
    }
    k3s_cluster = {
       children = {
         control_planes = {
           hosts = {
             for i in range(var.control_plane_count) : "${var.control_plane_name_prefix}-${i + 1}" => {
               ansible_host = cidrhost(var.subnet, var.control_plane_ip_offset + i)
             }
           }
         }
         workers = {
           hosts = {
             for i in range(var.worker_count) : "${var.worker_name_prefix}-${i + 1}" => {
               ansible_host = cidrhost(var.subnet, var.worker_ip_offset + i)
             }
           }
         }
       }
    }
  })
  filename = "${path.module}/../ansible/inventory.yml"
}