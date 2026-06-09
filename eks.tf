resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.eks_version
  enabled_cluster_log_types = [
    "api",
    "audit"
  ]
  vpc_config {
    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
      aws_subnet.public_1.id,
      aws_subnet.public_2.id
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name        = "${var.environment}-eks-cluster"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}
# -----------------------------------
# EKS NODE GROUP
# -----------------------------------

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  instance_types = [var.node_instance_type]

  disk_size = var.node_disk_size

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]

  tags = {
    Name        = "${var.environment}-node-group"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "eks"
  }
}