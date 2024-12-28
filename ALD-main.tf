# This block creates a Lambda function
resource "aws_lambda_function" "Lambda" {
  function_name = "Event-management"
  role          = aws_iam_role.lambda_role.arn
  layers        = [aws_lambda_layer_version.lambda_layer.arn]
  filename      = data.archive_file.function_zip.output_path
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  memory_size   = 128 //The amount of memory allocated to the Lambda function (in MB).
  timeout       = 60  //Timeout for the Lambda function (in seconds).
  tags = {
    Project = "EventManagement"
  }
}
# This block defines a Lambda layer containing shared dependencies required by the Lambda function.
resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "event-management-layer"
  filename            = data.archive_file.lambda_dependencies_zip.output_path //Path to the ZIP file containing the layer’s dependencies.
  compatible_runtimes = ["python3.13"]
  description         = "A layer for shared dependencies (boto3, requests)"
}
