output "instance_profile" {
  value = aws_iam_instance_profile.ec2.name
}

output "lambda_role" {
  value = aws_iam_role.lambda.arn
}
