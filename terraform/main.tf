provider "aws" {
  region = "us-east-1"
}

# Create ECR repositories for Docker images
resource "aws_ecr_repository" "web_receiver" {
  name = "pizza-shop-web-receiver"
}

resource "aws_ecr_repository" "transformer" {
  name = "pizza-shop-transformer"
}

resource "aws_ecr_repository" "repository" {
  name = "pizza-shop-repository"
}

# IAM role for EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "pizza-shop-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# IAM role policy attachment for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM role for EKS Node Group
resource "aws_iam_role" "eks_node_role" {
  name = "pizza-shop-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# IAM role policy attachment for EKS Node Group
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSCNIPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_ec2_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# VPC, Subnets, and Security Groups Configuration
# This is simplified; you may need more configurations based on your network requirements
resource "aws_vpc" "pizza_shop_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pizza_shop_subnet1" {
  vpc_id     = aws_vpc.pizza_shop_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "pizza_shop_subnet2" {
  vpc_id     = aws_vpc.pizza_shop_vpc.id
  cidr_block = "10.0.2.0/24"
}

# EKS Cluster
resource "aws_eks_cluster" "pizza_shop" {
  name     = "pizza-shop-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.pizza_shop_subnet1.id, aws_subnet.pizza_shop_subnet2.id]
  }
}

# EKS Node Group
resource "aws_eks_node_group" "pizza_shop_nodes" {
  cluster_name    = aws_eks_cluster.pizza_shop.name
  node_group_name = "pizza-shop-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.pizza_shop_subnet1.id, aws_subnet.pizza_shop_subnet2.id]

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }
}