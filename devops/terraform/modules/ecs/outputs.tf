# ECS Module Outputs
# GitOps Integration: Expose resources for service deployments and monitoring

output "cluster_id" {
  description = "ID of the ECS cluster - used by ECS services"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Name of the ECS cluster - used in deployment scripts"
  value       = aws_ecs_cluster.main.name
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer - application endpoint"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB - for Route53 alias records"
  value       = aws_lb.main.zone_id
}

output "backend_target_group_arn" {
  description = "ARN of backend target group - for ECS service configuration"
  value       = aws_lb_target_group.backend.arn
}

output "frontend_target_group_arn" {
  description = "ARN of frontend target group - for ECS service configuration"
  value       = aws_lb_target_group.frontend.arn
}

output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks - for service definitions"
  value       = aws_security_group.ecs_tasks.id
}