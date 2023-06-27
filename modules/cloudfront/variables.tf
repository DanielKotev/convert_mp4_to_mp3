variable "bucketName" {}
variable "bucket_name" {}
variable "bucket_arn" {}
variable "certificateArn" {
  default = "arn:aws:acm:us-east-1:699509601278:certificate/0650ffe2-fdd4-4c9b-b85b-5840527bc172"
}

variable "cloudFrontComment" {
  default = "danik CloudFront distribution"
}

variable "cloudFrontDefaultRootObject" {
  default = "index.html"
}

variable "cloudFrontCertificateVersion" {
  default = "TLSv1.2_2021"
}

variable "hostedZoneId" {
  default = "Z0637605ZR276D7FVLBB"
}
