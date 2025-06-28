locals {
  ecr_name_backend  = "${var.project}-ecr-repo-${var.env}"
  ecr_name_frontend = "${var.project}-ui-ecr-repo-${var.env}"
  db_credentials    = jsondecode(data.aws_secretsmanager_secret_version.aurora_creds.secret_string)
  db_name           = "${var.project}_db_${var.env}"
}

module "devexchsvc_vpc" {
  source = "../../modules/network/vpc"
}

module "devexchsvc_ecs_cluster" {
  source  = "../../modules/compute/ecs"
  project = var.project
  env     = var.env
}
resource "aws_iam_role" "devexchsvc_task_ecr_role" {
  name = "${var.project}-task-ecr-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "devexchsvc_task_execution_role" {
  name = "${var.project}-task-execution-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "devexchsvc_iam_policy_attachement" {
  role       = aws_iam_role.devexchsvc_task_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "devexchsvc_iam_execution_role_policy_attachement" {
  role       = aws_iam_role.devexchsvc_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "secrets_access_policy" {
  name        = "${var.project}-secrets-access-${var.env}"
  description = "Allow ECS task to read Secrets Manager secret for ${var.project}-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:${var.project}-secret-${var.env}-*"
      }
    ]
  })
}

resource "aws_ecs_task_definition" "devexchsvc_task" {
  family = "${var.project}-ecs-task-definition-${var.env}"
  requires_compatibilities = [
    "FARGATE",
  ]

  container_definitions = jsonencode([
    {
      name  = local.ecr_name_backend
      image = "${var.backend_ecr_image}:${var.image_tag}"
      cpu   = 256
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.project}-ui-task-def-${var.env}"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      memory = 512
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
  cpu                = 256
  memory             = 512
  network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.devexchsvc_task_ecr_role.arn
  execution_role_arn = aws_iam_role.devexchsvc_task_execution_role.arn
}

resource "aws_service_discovery_private_dns_namespace" "devexchsvc" {
  name        = "${var.project}.local"
  vpc         = module.devexchsvc_vpc.vpc_id
  description = "Private DNS namespace for ${var.project}"
}

resource "aws_service_discovery_service" "backend_sd" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.devexchsvc.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "WEIGHTED"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}


resource "aws_security_group" "devexchsvc_sg" {
  name        = "${var.project}-sg-${var.env}"
  description = "AWS Security Group for ECS Fargate endpoint"
  vpc_id      = module.devexchsvc_vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "eighteen_ingress_rule" {
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.devexchsvc_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "devexchsvc_ingress_rule" {
  from_port         = 3000
  to_port           = 3000
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.devexchsvc_sg.id
}

resource "aws_vpc_security_group_egress_rule" "https_egress_rule" {
  security_group_id = aws_security_group.devexchsvc_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_lb" "devexchsvc_alb" {
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.devexchsvc_sg.id
  ]
  name     = "${var.project}-alb-${var.env}"
  internal = false
  subnets = [module.devexchsvc_vpc.main_public_subnet_id,
    module.devexchsvc_vpc.secondary_public_subnet_id
  ]
  depends_on = [module.devexchsvc_vpc]
}

resource "aws_lb_target_group" "devexchsvc_alb_target_group" {
  name        = "${var.project}-ts-alb-tg-${var.env}"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.devexchsvc_vpc.vpc_id
  target_type = "ip"
  health_check {
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_iam_role_policy_attachment" "attach_secrets_to_task_role" {
  role       = aws_iam_role.devexchsvc_task_ecr_role.name
  policy_arn = aws_iam_policy.secrets_access_policy.arn
}

resource "aws_lb_listener" "devexchsvc_aws_lb_listener" {
  load_balancer_arn = aws_lb.devexchsvc_alb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devexchsvc_alb_target_group.arn
  }
}

resource "aws_cloudwatch_log_group" "ecs_backend_logs" {
  name              = "/ecs/${var.project}-backend-task-def-${var.env}"
  retention_in_days = 7
}

resource "aws_ecs_service" "devexchsvc_service" {
  name             = "${var.project}-ecs-service-${var.env}"
  cluster          = module.devexchsvc_ecs_cluster.ecs_cluster_arn
  task_definition  = aws_ecs_task_definition.devexchsvc_task.arn
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  # tell ECS exactly which container+port to register in Cloud Map:
  service_registries {
    registry_arn = aws_service_discovery_service.backend_sd.arn
  }

  # force a fresh rollout so tasks immediately re-register
  force_new_deployment = true

  load_balancer {
    target_group_arn = aws_lb_target_group.devexchsvc_alb_target_group.arn
    container_name   = local.ecr_name_backend
    container_port   = 3000
  }

  network_configuration {
    subnets = [module.devexchsvc_vpc.main_private_subnet_id,
    module.devexchsvc_vpc.secondary_private_subnet_id]
    security_groups  = [aws_security_group.devexchsvc_sg.id]
    assign_public_ip = false
  }

  desired_count = 1
  depends_on    = [aws_lb_listener.devexchsvc_aws_lb_listener]
}


resource "aws_security_group" "devexchsvc_aurora_rds_sg" {
  name        = "${var.project}-sg-aurora-rds-${var.env}"
  description = "AWS Security Group for RDS Aurora Serverless"
  vpc_id      = module.devexchsvc_vpc.vpc_id
}


resource "aws_vpc_security_group_ingress_rule" "rds_ingress_rule" {
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.devexchsvc_aurora_rds_sg.id
  referenced_security_group_id = aws_security_group.devexchsvc_sg.id
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name = "${var.project}-aurora-subnet-group-${var.env}"
  subnet_ids = [
    module.devexchsvc_vpc.main_private_subnet_id,
    module.devexchsvc_vpc.secondary_private_subnet_id,
  ]
  tags = {
    Name = "${var.project}-aurora-subnet-group-${var.env}"
  }
}

resource "aws_rds_cluster" "aurora_serverless" {
  cluster_identifier = "${var.project}-aurora-rds-${var.env}"
  engine             = "aurora-postgresql"
  engine_version     = "15.13"
  engine_mode        = "provisioned"
  database_name      = local.db_name
  master_username    = local.db_credentials.username
  master_password    = local.db_credentials.password

  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.devexchsvc_aurora_rds_sg.id]
  skip_final_snapshot    = true

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 4
  }

  lifecycle {
    ignore_changes = [
      database_name,
    ]
  }
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = 2
  identifier         = "${var.project}-aurora-${count.index + 1}-${var.env}"
  cluster_identifier = aws_rds_cluster.aurora_serverless.id

  engine              = aws_rds_cluster.aurora_serverless.engine
  engine_version      = aws_rds_cluster.aurora_serverless.engine_version
  instance_class      = "db.serverless"
  publicly_accessible = false
}

resource "aws_cloudwatch_log_group" "ecs_ui_logs" {
  name              = "/ecs/${var.project}-ui-task-def-${var.env}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "devexchsvc_ui_task" {
  family                   = "${var.project}-ui-task-def-${var.env}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.devexchsvc_task_execution_role.arn
  task_role_arn            = aws_iam_role.devexchsvc_task_ecr_role.arn

  container_definitions = jsonencode([
    {
      name   = local.ecr_name_frontend
      image  = "${var.backend_ecr_image}:${var.image_tag}"
      cpu    = 256
      memory = 512
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.project}-backend-task-def-${var.env}"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_lb_target_group" "devexchsvc_ui_alb_target_group" {
  name        = "${var.project}-ui-alb-tg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.devexchsvc_vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener_rule" "frontend_rule" {
  listener_arn = aws_lb_listener.devexchsvc_aws_lb_listener.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }
  condition {
    path_pattern { values = ["/*"] }
  }
}

resource "aws_lb_listener_rule" "backend_rule" {
  listener_arn = aws_lb_listener.devexchsvc_aws_lb_listener.arn
  priority     = 10 # ← make this smaller
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devexchsvc_alb_target_group.arn
  }
  condition {
    path_pattern { values = ["/api/*"] }
  }
}


resource "aws_lb_target_group" "frontend_target_group" {
  name        = "${var.project}-ui-tg-${var.env}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.devexchsvc_vpc.vpc_id
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_ecs_service" "frontend_service" {
  name            = "${var.project}-ui-service-${var.env}"
  cluster         = module.devexchsvc_ecs_cluster.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.devexchsvc_ui_task.arn
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
    container_name   = local.ecr_name_frontend
    container_port   = 80
  }

  network_configuration {
    subnets          = [module.devexchsvc_vpc.main_private_subnet_id, module.devexchsvc_vpc.secondary_private_subnet_id]
    security_groups  = [aws_security_group.devexchsvc_sg.id]
    assign_public_ip = true
  }

  desired_count = 1
  depends_on    = [aws_lb_listener_rule.frontend_rule]
}
