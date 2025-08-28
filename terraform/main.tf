terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}



resource "aws_s3_bucket" "b" {
  bucket = "my-web-bucket-for-assignemnt-stake"

  tags = {
    Name = "My bucket"
  }
}


resource "aws_s3_bucket" "logs" {
  bucket = "my-web-bucket-for-assignemnt-logs"
}


resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}




resource "aws_s3_bucket_acl" "b_acl" {
  depends_on = [ aws_s3_bucket_ownership_controls.logs ]
  bucket = aws_s3_bucket.logs.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  s3_origin_id = "myS3Origin"
}


resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "S3OAC"
  description                       = "Origin Access control for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.b.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "myprefix"
  }



  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}



resource "aws_s3_bucket_policy" "WebBucket" {
  bucket = aws_s3_bucket.b.id
  policy = data.aws_iam_policy_document.WebBucket.json
}

data "aws_iam_policy_document" "WebBucket" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.b.arn}/*",
    ]
  }
}


resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs.json
}

data "aws_iam_policy_document" "logs" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.logs.arn}/*",
    ]
  }
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.logs.arn
    ]
  }

}




































































































# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 6.0"
#     }
#   }
# }

# # Configure the AWS Provider
# provider "aws" {
#   region = "us-east-1"
# }








# resource "aws_s3_bucket" "b" {
#   bucket = "web-stack-test-bucket-tettssa"

#   tags = {
#     Name = "My bucket"
#   }
# }


# resource "aws_s3_bucket" "logs" {
#   bucket = "web-stack-test-logs-bucket"
# }

# resource "aws_s3_bucket_ownership_controls" "logs" {
#   bucket = aws_s3_bucket.logs.id

#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }




# resource "aws_s3_bucket_acl" "logs" {
#   depends_on = [ aws_s3_bucket_ownership_controls.logs ]
#   bucket = aws_s3_bucket.logs.id
#   acl    = "private"
# }

# resource "aws_s3_bucket_public_access_block" "logs" {
#   bucket = aws_s3_bucket.logs.id

#   block_public_acls       = false
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# locals {
#   s3_origin_id = "myS3Origin"
# }

# resource "aws_cloudfront_origin_access_control" "default" {
#   name                              = "s3-OAC"
#   description                       = "S3 OAC Policy"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }
# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name              = aws_s3_bucket.b.bucket_regional_domain_name
#     origin_access_control_id = aws_cloudfront_origin_access_control.default.id
#     origin_id                = local.s3_origin_id
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   comment             = "Some comment"
#   default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = aws_s3_bucket.logs.bucket_domain_name
#     prefix          = "myprefix"
#   }



#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "allow-all"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   # Cache behavior with precedence 0
#   ordered_cache_behavior {
#     path_pattern     = "/content/immutable/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false
#       headers      = ["Origin"]

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 86400
#     max_ttl                = 31536000
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   # Cache behavior with precedence 1
#   ordered_cache_behavior {
#     path_pattern     = "/content/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = local.s3_origin_id

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   price_class = "PriceClass_200"

#   restrictions {
#     geo_restriction {
#       restriction_type = "whitelist"
#       locations        = ["US", "CA", "GB", "DE"]
#     }
#   }

#   tags = {
#     Environment = "production"
#   }

#   viewer_certificate {
#     cloudfront_default_certificate = true
#   }
# } 


# resource "aws_s3_bucket_policy" "web-bucket" {
#   bucket = aws_s3_bucket.b.id
#   policy = data.aws_iam_policy_document.web-bucket.json
# }

# data "aws_iam_policy_document" "web-bucket" {
#   statement {
#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }

#     actions = [
#       "s3:GetObject"
#     ]

#     resources = [
#       "${aws_s3_bucket.b.arn}/*"
#     ]
#   }
# }

# resource "aws_s3_bucket_policy" "Logspolicy" {
#   bucket = aws_s3_bucket.logs.id
#   policy = data.aws_iam_policy_document.logsPolicy.json
# }

# data "aws_iam_policy_document" "logsPolicy" {
#   statement {
#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }

#     actions = [
#       "s3:PutObject",
#     ]

#     resources = [
#       "${aws_s3_bucket.logs.arn}/*",
#     ]
#   }

#     statement {
#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }

#     actions = [
#       "s3:GetBucketAcl",
#     ]

#     resources = [
#       aws_s3_bucket.logs.arn
#     ]
#   }

# }