03 - Allocate a virtual machine in the cloud
============================================


### Objective(s)

* allocate a virtual machine in the *cloud*
* successfully connect to tha virtual machine via SSH


### Prerequisites

* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed locally
* credentials for a [supported](https://registry.terraform.io/browse/providers)
  cloud platform
* (Optional) additional requirements depending on the chosen *cloud provider*


### Task(s)

1. Create an account for a cloud provider of your choice (see [FAQ](https://github.com/lucendio/lecture-devops-infos/blob/main/faq.md))
2. Configure the credentials locally (process is different for each cloud provider)
3. Generate an SSH key-pair & (optionally) Define a *Terraform* resource to manage the SSH key
4. Define a *Terraform* resource to allocate a virtual machine - according to your provider, e.g.
   * AWS: [`aws_instance`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
   * DigitalOcean: [`digitalocean_droplet`](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet)
   * Hetzner: [`hetzner_server`](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server)
   * GCP: [`google_compute_instance`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_image)
   * Azure: [`azurerm_virtual_machine`](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html)
5. Ensure that the machine has a public IP assigned and incoming traffic to the SSH & (optionally) HTTP port are
   allowed (may require additional Terraform resource)
6. Use the private part of the previously generated SSH key and connect to the allocated machine
7. (optional) Install *Nginx* into the instance and confirm that the default page is being served
