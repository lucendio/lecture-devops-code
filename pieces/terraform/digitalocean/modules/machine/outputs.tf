output name {
  value = "${ digitalocean_droplet.machine.name }"
}

output ipv4 {
  value = "${ digitalocean_droplet.machine.ipv4_address }"
}
