module "machine" {
  source = "./modules/machine"

  pid = "${ var.projectId }"

  hostname = "my-machine"
  cpus = "1"
  memory = "1gb"
  imageId = "centos-7-x64"
  regionId = "fra1"

  sshKeyFilePath = "${ var.sshKeyPairPath }"
}
