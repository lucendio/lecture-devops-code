locals {
  type_default = "t3.nano"
}

locals {
  instance_count = 4
}

variable "type" { type = string, default = null }

locals {
  machines = [
    {
      name = "database",
      type = var.type == null ? local.type_default : var.type
    },
    { name = "app", type = "cpx41" },
    { name = "loadbalancer", type = "cpx41" }
  ]

  destroy = false
}



resource "hcloud_server" "servers" {
  count = 3

  image = "ubuntu-20.04"
  name = "srv-${count.index}"
  server_type = "cx11"
}

output "server-ips" {
  description = "list of server IPv4s"
  value = hcloud_server.servers.*.ipv4_address
}
