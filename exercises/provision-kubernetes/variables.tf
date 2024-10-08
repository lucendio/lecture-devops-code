variable "sshPublicKeyPath" {
  type = string
  description = "path to the public part of the SSH key pair"
}

variable "cidr" {
  type = string
}


variable "controlplane" {
  type = list(object({
    name = string
    size = string
  }))

  default = []
}

variable "nodes" {
  type = list(object({
    name = string
    size = string
  }))

  default = []
}
