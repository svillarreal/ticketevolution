provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "Environment" : "${var.env}"
    }
  }
}

provider "kubernetes" {
  # Tell it to read your local kubeconfig
  config_path    = pathexpand("~/.kube/config")
  # (optional) if you need a specific context:
  # config_context = "arn:aws:eks:us-east-1:851717133722:cluster/ticketevolution-eks-dev"
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand("~/.kube/config")
    # config_context = "arn:aws:eks:us-east-1:851717133722:cluster/ticketevolution-eks-dev"
  }
}
