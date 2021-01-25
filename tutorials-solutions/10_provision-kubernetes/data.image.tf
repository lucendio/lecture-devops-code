data "aws_ami" "image" {
  # NOTE: prevent multiple images from to occurring in the result
  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"
    values = [
      "ubuntu/images/*",
    ]
  }

  filter {
    name = "name"
    values = ["*20.04*"]
  }

  # NOTE: pin image by setting release date
  filter {
    name = "name"
    values = ["*20210105"]
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
