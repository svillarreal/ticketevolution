output "devexchsvc_url" {
  value       = aws_lb.devexchsvc_alb.dns_name
  description = "DevEx Challenge Service Public Service URL"
}

output "ecs_alb_dns" {
  value       = aws_lb.devexchsvc_alb.dns_name
  description = "The DNS name of the ECS ALB"
}
