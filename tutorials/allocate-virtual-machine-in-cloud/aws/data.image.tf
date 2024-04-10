data "aws_ami" "image" {
  # NOTE: prevent multiple images from to occurring in the result,
  #       but keep in mind that this makes the result not reproducible,
  #       because at some point in the future a newer build matching the
  #       same filter values will occur
  most_recent = true

  # NOTE: AWS Academy only allows to start machines based on their own images
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["*ubuntu*"]
  }

  filter {
    name = "name"
    values = ["*22.04*"]
  }

  filter {
    name = "name"
    values = ["*amd64-server*"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
