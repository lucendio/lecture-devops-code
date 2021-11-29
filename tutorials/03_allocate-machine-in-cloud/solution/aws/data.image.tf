data "aws_ami" "image" {
  # NOTE: prevent multiple images from to occurring in the result
  most_recent = true

  # NOTE: AWS Academy only allows to start machines based on their own images
  owners = ["amazon"]

  filter {
    name = "name"
    values = [
      "*Ubuntu*",
    ]
  }

  filter {
    name = "name"
    values = ["*20.04*"]
  }

  filter {
    name = "name"
    values = ["*Express*"]
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
