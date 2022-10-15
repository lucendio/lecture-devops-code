output "bucketName" {
  value = aws_s3_bucket.b.id
}

output "bucketFQDN" {
  value = aws_s3_bucket.b.bucket_domain_name
}

output "bucketDomain" {
  value = "${ aws_s3_bucket.b.id }.s3.${ aws_s3_bucket.b.region }.amazonaws.com"
}
