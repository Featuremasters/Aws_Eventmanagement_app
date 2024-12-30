output "api_gateway_url" {
  description = "The public URL for the API Gateway"
  value       = aws_apigatewayv2_stage.stage.invoke_url
}
