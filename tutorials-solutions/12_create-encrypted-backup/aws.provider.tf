provider "aws" {
  # NOTE: inherited from environment variable 'AWS_DEFAULT_REGION' if set;
  #       not respected if defined in ~/.aws/config or AWS_CONFIG_FILE
  region = "us-east-1"

  # NOTE: set named profile that you defined yourself in ~/.aws
  # profile = "edu"
}
