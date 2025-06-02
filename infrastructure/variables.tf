# ==========================================================================
# CleanPro Infrastructure Variables
# ==========================================================================
# Description: Variables for Terraform configuration to deploy CleanPro
# Author: Seno Paul
# ==========================================================================

# ==========================================================================
# General Settings
# ==========================================================================

variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "cleanpro"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production."
  }
}

variable "aws_region" {
  description = "AWS region to deploy resources (eu-west-1 is recommended for Israel)"
  type        = string
  default     = "eu-west-1"
  
  validation {
    condition     = contains(["eu-west-1", "eu-central-1", "us-east-1"], var.aws_region)
    error_message = "Please use one of the following regions: eu-west-1 (Ireland, lowest latency to Israel), eu-central-1 (Frankfurt), us-east-1 (N. Virginia)."
  }
}

# ==========================================================================
# VPC and Networking
# ==========================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_vpn_gateway" {
  description = "Enable VPN gateway for the VPC"
  type        = bool
  default     = false
}

# ==========================================================================
# RDS Database
# ==========================================================================

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "cleanprodb"
}

variable "db_username" {
  description = "Username for the PostgreSQL database"
  type        = string
  default     = "cleanproadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
  # No default provided for security reasons - should be provided via environment variable or secure input
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS database (GB)"
  type        = number
  default     = 20
  
  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 100
    error_message = "Allocated storage must be between 20 and 100 GB."
  }
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for the RDS database (GB) for autoscaling"
  type        = number
  default     = 100
  
  validation {
    condition     = var.db_max_allocated_storage >= 20
    error_message = "Maximum allocated storage must be at least 20 GB."
  }
}

variable "db_backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
  
  validation {
    condition     = var.db_backup_retention_period >= 0 && var.db_backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = false
}

# ==========================================================================
# ECS Cluster and Container
# ==========================================================================

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 5000
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container (in MiB)"
  type        = number
  default     = 512
}

variable "app_count" {
  description = "Number of container instances to run"
  type        = number
  default     = 2
  
  validation {
    condition     = var.app_count > 0
    error_message = "At least one container instance must be deployed."
  }
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/health"
}

variable "deployment_maximum_percent" {
  description = "Maximum percent of tasks that can be running during a deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percent of tasks that must remain healthy during a deployment"
  type        = number
  default     = 100
}

# ==========================================================================
# Load Balancer
# ==========================================================================

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  # No default as this should be provided for each environment
}

variable "lb_idle_timeout" {
  description = "Idle timeout for the load balancer in seconds"
  type        = number
  default     = 60
}

variable "lb_access_logs_enabled" {
  description = "Enable access logs for the load balancer"
  type        = bool
  default     = true
}

variable "lb_access_logs_expiration_days" {
  description = "Number of days to retain load balancer access logs"
  type        = number
  default     = 90
}

# ==========================================================================
# Monitoring and Logging
# ==========================================================================

variable "enable_container_insights" {
  description = "Enable Container Insights for ECS cluster"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
  
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "Log retention must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

# ==========================================================================
# Tags
# ==========================================================================

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

