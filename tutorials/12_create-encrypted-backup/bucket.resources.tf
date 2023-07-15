resource "aws_s3_bucket" "b" {
  bucket = join( "-", concat(
    var.bucketPrefix != null ? [ random_string.suffix[0].keepers.bucketPrefix ] : [],
    [ for _, parts in random_string.suffix : parts.result ],
  ))

  # Could be changed to 'public-read' if asymmetric cryptography is being used
  acl    = "private"

  versioning {
    enabled = false
  }

  force_destroy = true

  lifecycle_rule {
    enabled = false

    expiration {
      days = 1
    }
  }
}


resource "random_string" "suffix" {
  count = var.bucketPrefix != null ? 1 : 4

  length = 6

  lower   = true
  upper   = false
  number  = true
  special = false

  keepers = {
    bucketPrefix = var.bucketPrefix
  }
}
