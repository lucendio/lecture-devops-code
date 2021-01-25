cidr = "192.168.23.0/24"

controlplane = [
  {
    name = "instance1"
    size = "t2.small"
  }
]

nodes = [
  {
    name = "node1"
    size = "t2.small"
  },
  {
    name = "node2"
    size = "t2.small"
  }
]
