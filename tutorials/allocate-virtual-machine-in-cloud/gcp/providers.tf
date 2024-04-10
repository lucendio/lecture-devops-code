provider "google" {
  # NOTE: ID, not name
  project = var.projectID

  # NOTE: Frankfurt Main
  # DOCS: https://cloud.google.com/compute/docs/regions-zones
  zone = "europe-west3-b"

  credentials = var.gcpCredentialsFilePath
}
