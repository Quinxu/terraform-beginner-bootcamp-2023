#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform_bucket" {
  #Bucket Naming Rules
  #https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html
  # bucket = var.bucket_name #want to assign a random bucket name

  tags = {
    UserUuid = var.user_uuid
  }
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.terraform_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }  
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  key    = "index.html"
  source = "${var.carving_public_path}/index.html"
  content_type = "text/html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${var.carving_public_path}/index.html")
  lifecycle {
    ignore_changes = [
      # Ignore changes to index.html
      etag
    ]
    replace_triggered_by = [
      # replace index.html when content version changes
      terraform_data.content_version
    ]
  }
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  key    = "error.html"
  source =  "${var.carving_public_path}/error.html"
  content_type = "text/html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${var.carving_public_path}/error.html")
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.terraform_bucket.bucket
  # policy = data.aws_iam_policy_document.allow_access_from_another_account.json
  policy = jsonencode({
      "Version"= "2012-10-17",
      "Statement"= {
          "Sid": "AllowCloudFrontServicePrincipalReadOnly",
          "Effect": "Allow",
          "Principal": {
              "Service": "cloudfront.amazonaws.com"
          },
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${aws_s3_bucket.terraform_bucket.bucket}/*",
          "Condition": {
              "StringEquals": {  
                "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
              }
          }
      }
    })
}

resource "terraform_data" "content_version" {
  input = var.carving_content_version
}

resource "aws_s3_object" "upload_assets" {
  # bucket = aws_s3_bucket.example_bucket.bucket
  # acl    = "private"
  
  #https://developer.hashicorp.com/terraform/language/functions/fileset
  #https://developer.hashicorp.com/terraform/language/functions/toset

  for_each = fileset("${var.carving_public_path}/assets","*.{jpg,png,gif}")
  bucket = aws_s3_bucket.terraform_bucket.bucket
  key    = "assets/${each.key}"
  source = "${var.carving_public_path}/assets/${each.key}"
  # key    = "index.html"
  # source = var.index_html_file_path
  #content_type = "text/html"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("${var.carving_public_path}/assets/${each.key}")
  lifecycle {
    ignore_changes = [
      # Ignore changes to index.html
      etag
    ]
    replace_triggered_by = [
      # replace index.html when content version changes
      terraform_data.content_version
    ]
  }
}