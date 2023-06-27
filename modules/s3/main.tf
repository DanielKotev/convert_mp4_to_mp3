resource "aws_s3_bucket" "danikBucket" {
  bucket = "danik-s3"

  website {
    index_document = "public-read"
  }
}

resource "aws_s3_bucket_ownership_controls" "danikBucketOwnership" {
  bucket = aws_s3_bucket.danikBucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "danikOffBlockPublicAcces" {
  bucket = aws_s3_bucket.danikBucket.id


  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.danikBucketOwnership,
    aws_s3_bucket_public_access_block.danikOffBlockPublicAcces,
  ]

  bucket = aws_s3_bucket.danikBucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_cors_configuration" "danikBucketCors" {
  bucket = aws_s3_bucket.danikBucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "POST", "PUT", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

resource "aws_s3_object" "uploadedFolder" {
  bucket     = var.bucketName
  key        = "uploaded/"
  acl        = "public-read"
  depends_on = [aws_s3_bucket.danikBucket, aws_s3_bucket_ownership_controls.danikBucketOwnership, aws_s3_bucket_public_access_block.danikOffBlockPublicAcces, aws_s3_bucket_acl.example]
}

resource "aws_s3_object" "uploadedFolder2" {
  bucket     = var.bucketName
  key        = "processed/"
  acl        = "public-read"
  depends_on = [aws_s3_bucket.danikBucket, aws_s3_bucket_ownership_controls.danikBucketOwnership, aws_s3_bucket_public_access_block.danikOffBlockPublicAcces, aws_s3_bucket_acl.example]
}

/* locals {
  zip_file_path = "/home/ec2-user/taskFromNik/modules/s3/mypackage.zip"
} 

resource "aws_s3_object" "uploadPackageFile" {
  bucket = var.bucketName
  key = "mypackage.zip"
  source = local.zip_file_path
} */

output "bucket_name" {
  value = aws_s3_bucket.danikBucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.danikBucket.arn
}

output "bucketName" {
  value = var.bucketName
}
