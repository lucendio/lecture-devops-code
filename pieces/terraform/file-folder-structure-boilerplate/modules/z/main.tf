variable "environment" {
  type = string
  description = "infra setup with dedicated semantics"
  // NOTE: mandatory if no 'default' is defined
}

variable "region" {
  type = string
  description = "region where the infra is hosted"
  default = "fra1"
}

resource "digitalocean_vpc" "example" {
  name = "${var.environment}-network"
  region = var.region
}
