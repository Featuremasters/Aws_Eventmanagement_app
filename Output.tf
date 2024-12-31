output "frontend_public_url" {
  description = "Public URL to access the frontend website"
  value       = "http://${aws_instance.Event-management-app.public_ip}"
}