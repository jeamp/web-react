provider "aws" {
  region     = "us-east-1"
  access_key = "${AWS_ACCESS_KEY}"
  secret_key = "${AWS_SECRET_KEY}"
}
variable "folder_name" {
  type = string
  default = "build"
}

resource "aws_s3_bucket_object" "object" {
  bucket = "react-web"
  acl    = "private"
  key = "${var.folder_name}"
  source = "${var.folder_name}/"
  etag = filemd5("${var.folder_name}")
}