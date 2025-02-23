resource "aws_lambda_function" "cw" {
  function_name    = "observ-cw-lambda"
  runtime          = "python3.9"
  role             = var.role
  handler          = "main.handler"
  filename         = "${path.module}/main.zip"
  source_code_hash = data.archive_file.cw.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      "CW_REGION"   = var.region
      "INSTANCE_ID" = var.instance
    }
  }
  logging_config {
    log_group  = var.log_group
    log_format = "Text"
  }
}
