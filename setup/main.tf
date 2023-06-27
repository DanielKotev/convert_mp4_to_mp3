terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

module "cognito" {
  source     = "../modules/cognito"
  userPoolId = module.cognito.userPoolId
  clientId   = module.cognito.clientId
}

module "s3" {
  source = "../modules/s3"
}

module "index" {
  source           = "../modules/index"
  region           = "eu-central-1"
  clientId         = module.cognito.clientId
  identity_pool_id = module.cognito.identity_pool_id
  userPoolId       = module.cognito.userPoolId
  bucketName       = module.s3.bucket_name
  depends_on       = [module.s3, module.cognito]
}

/* module "acm" {
  source           = "../modules/acm"
}
 */
module "cloudfront" {
  source      = "../modules/cloudfront"
  bucket_name = module.s3.bucket_name
  bucket_arn  = module.s3.bucket_arn
  bucketName  = module.s3.bucketName
  depends_on  = [module.index]
}

module "queue" {
  source = "../modules/queue"
}


module "first_lambda" {
  source     = "../modules/first_lambda"
  bucketName = module.s3.bucket_name
  bucket_arn = module.s3.bucket_arn
  queueUrl   = module.queue.queueUrl
  depends_on = [module.cloudfront, module.queue]
}

module "second_Lambada" {
  source     = "../modules/second_lambda"
  bucketName = module.s3.bucket_name
  bucket_arn = module.s3.bucket_arn
  queueArn   = module.queue.queueArn
  depends_on = [module.first_lambda]
}
