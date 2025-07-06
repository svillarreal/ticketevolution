variable "project" {
  default = "ticketevolution"
}

variable "env" {
  default = "dev"
}

variable "backend_ecr_image" {
  default = "851717133722.dkr.ecr.us-east-1.amazonaws.com/ticketevolution-ecr-repo-dev"
}

variable "frontend_ecr_image" {
  default = "851717133722.dkr.ecr.us-east-1.amazonaws.com/ticketevolution-ui-ecr-repo-dev"
}

variable "image_tag" {
  default = "latest"
}
