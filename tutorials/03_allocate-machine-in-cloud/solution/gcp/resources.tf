locals {
  sshUserName = "ubuntu"
}

resource "google_compute_instance" "vm" {
  name         = "my-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image.self_link
    }
  }

  network_interface {
    network = google_compute_network.nw.name
    # NOTE: dynamically assign a public IP
    access_config { }
  }

  metadata = {
    ssh-keys = "${ local.sshUserName }:${ file(var.sshPublicKeyPath) }"
  }
}


resource "google_compute_network" "nw" {
  name = "my-network"
}


resource "google_compute_firewall" "fw" {
  name    = "my-firewall"
  network = google_compute_network.nw.name


  # NOTE: enable `ping`
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = [
      "22",
      "80"
    ]
  }

  source_ranges = ["0.0.0.0/0"]
}
