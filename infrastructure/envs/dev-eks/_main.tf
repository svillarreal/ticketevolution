locals {
  cluster_name = "${var.project}-eks-${var.env}"
  k8s_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "ticketevol_vpc" {
  source              = "../../modules/network/vpc"
  private_subnet_tags = local.k8s_tags
  public_subnet_tags  = local.k8s_tags
}

module "eks_ebs_csi_irsa_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name             = "${local.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_version = "1.29"
  vpc_id          = module.ticketevol_vpc.vpc_id
  cluster_name    = local.cluster_name
  subnet_ids = [
    module.ticketevol_vpc.main_private_subnet_id,
    module.ticketevol_vpc.secondary_private_subnet_id
  ]

  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true
  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types  = ["t3.medium"]
      capacity_type   = "SPOT"
      create_iam_role = true

      iam_role_additional_policies = {
        "AmazonEC2ContainerRegistryReadOnly" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        "AmazonEKSWorkerNodePolicy"          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        "AmazonEKS_CNI_Policy"               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      }
    }
  }
  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.eks_ebs_csi_irsa_role.iam_role_arn
      most_recent              = true
    }
  }
}

module "aws_lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${local.cluster_name}-aws-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

}

resource "kubernetes_namespace" "ticketevol_be_ns" {
  metadata {
    name = "ticketevol-be"
  }
}


resource "kubernetes_namespace" "ticketevol_fe_ns" {
  metadata {
    name = "ticketevol-fe"
  }
}

resource "kubernetes_service_account" "lb_service_account" {
  metadata {
    namespace = "kube-system"
    name      = "aws-load-balancer-controller"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::851717133722:role/ticketevolution-eks-dev-aws-lb-controller"
    }
  }
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "random_password" "db_postgres_password" {
  length  = 16
  special = true
}

resource "helm_release" "postgresql" {
  name       = "ticketevolution-pg"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = "ticketevol-be"
  version    = "15.2.0"

  values = [
    yamlencode({
      auth = {
        # super-user ("postgres") password
        password         = random_password.db_password.result
        postgresPassword = random_password.db_postgres_password.result
        # application user to create
        username = "ticketevolutionapp"
        # database to create
        database = "ticketevolutiondb"
      }
      # (optional) enable persistence, tweak size, etc.
      primary = {
        persistence = {
          enabled = true
          size    = "8Gi"
        }
      }
    })
  ]
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

