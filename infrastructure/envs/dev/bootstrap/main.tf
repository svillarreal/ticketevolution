locals {
  ecr_name    = "${var.project}-ecr-repo-${var.env}"
  ecr_name_ui = "${var.project}-ui-ecr-repo-${var.env}"
}

resource "aws_secretsmanager_secret" "aurora_secret" {
  name                    = "${var.project}-secret-${var.env}"
  recovery_window_in_days = 7
  description             = "Secret for devexchsvc Aurora Serverless v2 PostgreSQL master user password"
}


resource "aws_ecr_repository" "devexchsvc_ui_ecr" {
  name         = local.ecr_name_ui
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "devexchsvc_ecr" {
  name         = local.ecr_name
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}
