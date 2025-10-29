# ECS Module - Manages containerized application deployment
# This demonstrates GitOps container orchestration without Kubernetes
# ECS provides AWS-native container management with auto-scaling

# ECS Cluster - Logical grouping of compute resources
# Acts as the foundation for running containerized services
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"

  # Enable container insights for monitoring and observability
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-ecs-cluster"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ECS Cluster Capacity Providers - Define compute options
# Fargate provides serverless containers (no EC2 management)
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # Default capacity provider strategy
  # Fargate for consistent performance, Spot for cost optimization
  default_capacity_provider_strategy {
    base              = 1        # Minimum tasks on regular Fargate
    weight            = 100      # Percentage of tasks on regular Fargate
    capacity_provider = "FARGATE"
  }

  default_capacity_provider_strategy {
    base              = 0        # No minimum on Spot
    weight            = 0        # Start with 0% on Spot (can be adjusted per service)
    capacity_provider = "FARGATE_SPOT"
  }
}

# Application Load Balancer - Distributes traffic across containers
# Provides high availability and health checking
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false  # Internet-facing load balancer
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  # Enable deletion protection in production
  enable_deletion_protection = var.environment == "prod"

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ALB Target Group - Defines health check and routing for backend
resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-${var.environment}-backend"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"  # Required for Fargate

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = 2      # Consecutive successful checks
    interval            = 30     # Seconds between checks
    matcher             = "200"  # Expected HTTP response code
    path                = "/"    # Health check endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5      # Seconds to wait for response
    unhealthy_threshold = 2      # Consecutive failed checks
  }

  tags = {
    Name        = "${var.project_name}-backend-tg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ALB Target Group for Frontend
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-${var.environment}-frontend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-frontend-tg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ALB Listener - Routes incoming requests to appropriate target groups
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Default action - route to frontend
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ALB Listener Rule - Route API requests to backend
resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]  # Route API calls to backend
    }
  }
}

# Security Group for ALB - Controls inbound traffic
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  vpc_id      = var.vpc_id

  # Allow HTTP traffic from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic from internet (for future SSL implementation)
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security Group for ECS Tasks - Controls container network access
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-tasks-"
  vpc_id      = var.vpc_id

  # Allow traffic from ALB
  ingress {
    description     = "Traffic from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow all outbound traffic (for database, external APIs, etc.)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ecs-tasks-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}