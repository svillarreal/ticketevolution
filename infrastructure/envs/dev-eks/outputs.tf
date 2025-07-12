output "load_balancer_arn" {
  description = "App Load Balancer ARN"
  value       = module.aws_lb_controller_irsa.iam_role_arn
}
