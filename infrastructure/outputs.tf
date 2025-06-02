# ==========================================================================
# CleanPro Infrastructure Outputs
# ==========================================================================
# Description: Output values from Terraform resources
# Author: Seno Paul
# ==========================================================================

# ==========================================================================
# VPC and Networking Outputs
# ==========================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

# ==========================================================================
# RDS Database Outputs
# ==========================================================================

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.postgresql.address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.postgresql.arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.postgresql.endpoint
}

output "db_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.postgresql.id
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.postgresql.name
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.postgresql.port
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.postgresql.username
  sensitive   = true
}

output "db_subnet_group_name" {
  description = "The database subnet group name"
  value       = aws_db_subnet_group.rds_subnet_group.name
}

output "db_connection_string" {
  description = "PostgreSQL connection string (password excluded for security)"
  value       = "postgresql://${aws_db_instance.postgresql.username}:PASSWORD@${aws_db_instance.postgresql.endpoint}/${aws_db_instance.postgresql.name}"
  sensitive   = true
}

# ==========================================================================
# Load Balancer Outputs
# ==========================================================================

output "lb_id" {
  description = "The ID of the load balancer"
  value       = aws_lb.main.id
}

output "lb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "lb_zone_id" {
  description = "The zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "target_group_name" {
  description = "The name of the target group"
  value       = aws_lb_target_group.app.name
}

output "application_url" {
  description = "The URL of the application"
  value       = "https://${aws_lb.main.dns_name}"
}

# ==========================================================================
# ECS Cluster Outputs
# ==========================================================================

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# Note: The actual services and tasks will be added in the ECS service definition
# which is not part of this basic infrastructure setup

# ==========================================================================
# Security Group Outputs
# ==========================================================================

output "alb_security_group_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "ecs_task_security_group_id" {
  description = "The ID of the ECS task security group"
  value       = aws_security_group.ecs_task_sg.id
}

output "rds_security_group_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}

# ==========================================================================
# S3 Bucket Outputs
# ==========================================================================

output "lb_logs_bucket_name" {
  description = "The name of the S3 bucket for ALB logs"
  value       = aws_s3_bucket.lb_logs.id
}

output "lb_logs_bucket_arn" {
  description = "The ARN of the S3 bucket for ALB logs"
  value       = aws_s3_bucket.lb_logs.arn
}

# ==========================================================================
# General Information
# ==========================================================================

output "region" {
  description = "The AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "The environment (dev, staging, production)"
  value       = var.environment
}

output "project_name" {
  description = "The name of the project"
  value       = var.project_name
}

output "deployment_timestamp" {
  description = "Timestamp of the deployment"
  value       = timestamp()
}

