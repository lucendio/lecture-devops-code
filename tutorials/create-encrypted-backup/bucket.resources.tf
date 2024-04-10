resource "aws_s3_bucket" "b" {
  bucket = join( "-", concat(
    var.bucketPrefix != null ? [ random_string.suffix[0].keepers.bucketPrefix ] : [],
    [ for _, parts in random_string.suffix : parts.result ],
  ))

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "b" {
  bucket = aws_s3_bucket.b.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "b" {
  bucket = aws_s3_bucket.b.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "b" {
  bucket = aws_s3_bucket.b.id

  # Could be changed to 'public-read' if asymmetric cryptography is being used
  acl = "private"

  depends_on = [ aws_s3_bucket_ownership_controls.b ]
}

resource "aws_s3_bucket_lifecycle_configuration" "b" {
  bucket = aws_s3_bucket.b.id

  rule {
    id = "first"
    status = "Disabled"
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
  numeric = true
  special = false

  keepers = {
    bucketPrefix = var.bucketPrefix
  }
}
