# This block creates a ZIP archive of the Lambda function code.
data "archive_file" "function_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}
# This block creates a ZIP archive of the Dependency folder.
data "archive_file" "lambda_dependencies_zip" {
  type        = "zip"
  source_dir  = "Dependency/"
  output_path = "dependencies.zip"
}