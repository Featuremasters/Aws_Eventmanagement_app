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

resource "aws_dynamodb_table" "Event-table" {
  name         = "event-management"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_id" # Partition key
   range_key      = "event_date" #Sort key

  attribute {
    name = "event_id"
    type = "N" # S: String, N: Number, B: Binary
  }
  attribute {
    name = "event_date"
    type = "N"
  }
  tags = {
    Project = "EventManagement"
  }
}

# HTTP API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "event-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers  = ["*"]
    allow_methods  = ["*"]
    allow_origins  = ["*"]
    expose_headers = ["*"]
    max_age        = 3600
  }
}

# Lambda Function Integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.Lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# API Route for POST /api/events
resource "aws_apigatewayv2_route" "post_event" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /api/events"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Deploy API
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "production"
  auto_deploy = true
}
