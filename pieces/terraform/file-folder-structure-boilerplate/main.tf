terraform {
  required_version = "~> 0.12"

  backend s3 {
    # Set as command line option in Makefile:
    #   bucket            --> name of the s3 bucket storing the state
    #   key               --> path, that is appended to the bucket
    #   dynamodb_table    --> used to store the TF state lock
    #   sse_customer_key  --> encryption key for the state file

    encrypt = true
  }
}
