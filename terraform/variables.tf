variable "region" {
  description = "Aws Region deploy"
  type        = string
}

variable "profile" {
  description = "Aws auth profile"
  type        = string
}

variable "bucket_name" {
  description = "Bucket Name"
  type        = string
}

variable "env" {
  description = "Deploy environment"
  type        = string
}