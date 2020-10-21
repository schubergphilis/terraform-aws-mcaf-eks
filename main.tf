resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = 7
}

resource "aws_eks_cluster" "default" {
  name                      = "default"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  role_arn                  = aws_iam_role.default.arn
  tags                      = var.tags


  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_cloudwatch_log_group.default,
    aws_iam_role_policy_attachment.default-AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.default.name
  instance_types  = ["t3.small"]
  node_group_name = "default_node"
  node_role_arn   = aws_iam_role.default_node_group.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.poc-cluster-node-group-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.poc-cluster-node-group-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.poc-cluster-node-group-AmazonEKSWorkerNodePolicy,
  ]
}

resource "aws_iam_role" "default" {
  name = "RoleEksCluster"
  tags = var.tags

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [{
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Effect" : "Allow"
      }]
    }
  )
}

resource "aws_iam_role" "default_node_group" {
  name = "RoleEksClusterNodeGroup"
  tags = var.tags

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "default-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.default.name
}

resource "aws_iam_role_policy_attachment" "poc-cluster-node-group-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.default_node_group.name
}

resource "aws_iam_role_policy_attachment" "poc-cluster-node-group-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.default_node_group.name
}

resource "aws_iam_role_policy_attachment" "poc-cluster-node-group-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.default_node_group.name
}