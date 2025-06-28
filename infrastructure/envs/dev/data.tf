data "aws_secretsmanager_secret_version" "aurora_creds" {
  secret_id = "${var.project}-secret-${var.env}"
}


data "aws_caller_identity" "current" {}
