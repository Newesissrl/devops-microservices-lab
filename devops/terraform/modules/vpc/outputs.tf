# VPC Module Outputs
# GitOps Principle: Expose necessary resource identifiers for other modules
# These outputs enable loose coupling between infrastructure components

output "vpc_id" {
  description = "ID of the VPC - used by other modules to reference this network"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC - useful for security group rules"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets - where load balancers will be deployed"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets - where ECS tasks will run"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway - for additional routing if needed"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways - for monitoring and cost tracking"
  value       = aws_nat_gateway.main[*].id
}