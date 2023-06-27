resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  policy = jsonencode({

    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:Describe*",
          "cloudwatch:*",
          "logs:*",
          "sns:*",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRole",
          "oam:ListSinks"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : "events.amazonaws.com"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "oam:ListAttachedLinks"
        ],
        "Resource" : "arn:aws:oam:*:*:sink/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ses:*"
        ],
        "Resource" : "*"
      },
      {
        "Action" : [
          "sqs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Resource" : "*"
      }
    ]
  })
  role = aws_iam_role.lambda_role.name
}

data "archive_file" "zipPythonCode" {
  type        = "zip"
  source_dir  = "${path.module}/layer/"
  output_path = "${path.module}/layer/first_lambda.zip"
}

resource "aws_lambda_layer_version" "my_layer" {
  compatible_architectures = ["x86_64"]
  compatible_runtimes      = ["python3.7"]
  layer_name               = "myLayer"
  s3_bucket                = "danik-s3"
  s3_key                   = "layer.zip"
}

resource "aws_lambda_function" "s3_lambda" {
  function_name    = "s3_lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "first_lambda.lambda_handler"
  runtime          = "python3.7"
  source_code_hash = base64sha256(data.archive_file.zipPythonCode.output_path)
  filename         = data.archive_file.zipPythonCode.output_path
  timeout          = 300
  layers           = [aws_lambda_layer_version.my_layer.arn]
}


resource "aws_lambda_permission" "s3_lambda_permission1" {
  statement_id  = "AllowExecutionFromS3_1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket     = var.bucketName
  depends_on = [aws_lambda_permission.s3_lambda_permission1]

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploaded/"
  }
}

output "awslambdafunc1" {
  value = aws_lambda_function.s3_lambda.arn
}
