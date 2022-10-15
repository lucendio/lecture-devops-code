variable "sshPublicKeyPath" {
  type = string
  description = "path to the public part of the SSH key pair"
}

variable "gcpCredentialsFilePath" {
  type = string
  description = "path to a GCP credentials file (e.g. service account key)"
}
