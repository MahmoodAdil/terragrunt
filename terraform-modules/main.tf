# terraform-modules/my-module/main.tf
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-unique-bucket-name"
  acl    = "private"
}
