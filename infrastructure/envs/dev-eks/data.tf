data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "auth" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}
