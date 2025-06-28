variable "project" {
  default = "devexchsvc"
}

variable "env" {
  default = "dev"
}

variable "backend_ecr_image" {
  default = "851717133722.dkr.ecr.us-east-1.amazonaws.com/devexchsvc-ecr-repo-dev"
}

variable "frontend_ecr_image" {
  default = "851717133722.dkr.ecr.us-east-1.amazonaws.com/devexchsvc-ui-ecr-repo-dev"
}

variable "image_tag" {
  default = "latest"
}
