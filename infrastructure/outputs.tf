output "application_url" {
  description = "Public CloudFront URL for the application"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}


output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}


output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}


output "rds_endpoint" {
  description = "Private PostgreSQL endpoint"
  value       = aws_db_instance.postgres.endpoint
}


output "autoscaling_group_name" {
  description = "Backend Auto Scaling group name"
  value       = aws_autoscaling_group.backend.name
}


output "frontend_bucket_name" {
  description = "Private frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}


output "artifact_bucket_name" {
  description = "Private backend artifact S3 bucket"
  value       = aws_s3_bucket.artifacts.id
}