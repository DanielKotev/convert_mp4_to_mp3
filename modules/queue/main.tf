resource "aws_sqs_queue" "Queue" {
  name                       = "my_queue"
  visibility_timeout_seconds = 300
}

output "queueUrl" {
  value = aws_sqs_queue.Queue.url
}

output "queueArn" {
  value = aws_sqs_queue.Queue.arn
}
