output "ticketevol_url" {
  value       = aws_lb.ticketevol_alb.dns_name
  description = "Ticket Evolution Service Public Service URL"
}

output "ecs_alb_dns" {
  value       = aws_lb.ticketevol_alb.dns_name
  description = "The DNS name of the ECS ALB"
}
