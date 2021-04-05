locals {
  servers = [
    { name = "foo" },
    { name = "bar", type = "cpx41" }
  ]
}

resource "hcloud_server" "machines" {
  for_each = { for srv in local.servers : srv.name => srv }

  image = "ubuntu-20.04"
  name = each.key
  server_type = lookup(each.value, "type", "cx11" )
}
