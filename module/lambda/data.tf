data "archive_file" "cw" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "${path.module}/main.zip"
}
