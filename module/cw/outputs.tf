output "ec2_cw_arn" {
  value = aws_cloudwatch_log_group.ec2.arn
}

output "ec2_cw" {
  value = aws_cloudwatch_log_group.ec2.name
}

output "lambda_cw_arn" {
  value = aws_cloudwatch_log_group.lambda.arn
}

output "lambda_cw" {
  value = aws_cloudwatch_log_group.lambda.name
}
