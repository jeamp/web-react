terraform {
  backend "s3" {
    bucket  = "state-bucket-jesmartinez"
    key     = "dev/terraform.tfstate"
    encrypt = true
    region  = "us-east-1"
    profile = "personal"
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  tags = {
    name = "Test"
    env  = "${var.env}"
  }
}

locals {
  s3_origin_id = "webS3Orgin"
}

resource "aws_cloudfront_origin_access_identity" "WebOAI" {
  comment = "Web Indentity"
}

resource "aws_s3_bucket_policy" "allow_acces_from_weboai" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.allow_acces_from_weboai.json
}

data "aws_iam_policy_document" "allow_acces_from_weboai" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.WebOAI.iam_arn]
    }

    actions = ["s3:GetObject"]

    resources = [
      aws_s3_bucket.s3_bucket.arn,
      "${aws_s3_bucket.s3_bucket.arn}/*",
    ]

  }
}

resource "aws_cloudfront_distribution" "web-react-cloudfront" {
  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.WebOAI.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}