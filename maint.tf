provider "aws" {
    region = var.AWS_REGION
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY 

}

terraform { 

  required_providers { 

    aws = { 

      source  = "hashicorp/aws" 

    } 

    kubernetes = { 

      source  = "hashicorp/kubernetes" 

    } 

  } 
}

provider "kubernetes" { 

  # Set this value to "/etc/rancher/k3s/k3s.yaml" if using K3s 
  #host = ressource.aws_eks_cluster.group7.endpoint
  #config_path    = "~/.kube/config" 

}   

resource "aws_vpc" "group7" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "group7"
  }
}

resource "aws_subnet" "public-subnet-in-us-east-2" {
  vpc_id = aws_vpc.group7.id

  cidr_block        = "10.0.0.0/16"
  availability_zone = "us-east-2a"

  tags = {
    Name = "Vault Public Subnet"
  }
} 
resource "aws_eks_cluster" "group7" {
  name     = "group7"
   role_arn = aws_iam_role.group7.arn 

  vpc_config {
    #name = "terraform-test-sg-group7"
    subnet_ids = aws_subnet.public-subnet-in-us-east-2.*.id
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
 /* depends_on = [
    aws_iam_role_policy_attachment.group7-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.group7-AmazonEKSVPCResourceController,
  ]*/
}

output "endpoint" {
  value = aws_eks_cluster.group7.endpoint
}

/*output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.example.certificate_authority[0].data
}
*/
resource "aws_eks_node_group" "group7" {
  cluster_name    = aws_eks_cluster.group7.name
  node_group_name = "Group7"
  node_role_arn   = aws_iam_role.group7.arn
  subnet_ids      = toset([element(aws_subnet.public-subnet-in-us-east-2.*.id,0)]) #toset(aws_subnet.public-subnet-in-us-east-2.id)

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 3
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  /* depends_on = [
    aws_iam_role_policy_attachment.HackathonPolicy
   /*  aws_iam_role_policy_attachment.group7-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.group7-AmazonEC2ContainerRegistryReadOnly, */
  /* ] * */
}
/*resource "aws_iam_role" "group7" {
  name = "eks-node-group-group7"

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
}*/

 /* resource "aws_iam_role_policy_attachment" "group7-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.group7.name
}

resource "aws_iam_role_policy_attachment" "group7-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.group7.name
}

  resource "aws_iam_role_policy_attachment" "group7-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.group7.name
}*/


resource "aws_iam_role" "group7" {
  name = "HackathonPolicy"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Hackathon AWS",
      "Effect": "Allow",
      "Action": [
                "iam:GetUserPolicy",
                "iam:ListGroupsForUser",
                "iam:ListAttachedUserPolicies",
                "iam:ListUserPolicies",
                "iam:GetUser"
            ],
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AllowAll",
      "Ressource": "*"
    }
  ]
}
POLICY
}
 /* assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:ListAttachedRolePolicies",
                "iam:GetPolicyVersion",
                "iam:ListRoleTags",
                "iam:PutRolePermissionsBoundary",
                "iam:ListPoliciesGrantingServiceAccess",
                "iam:DeletePolicy",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "iam:PassRole",
                "iam:DetachRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:ListPolicyTags",
                "iam:CreatePolicyVersion",
                "iam:ListRolePolicies",
                "iam:ListPolicies",
                "iam:GetRole",
                "cloudshell:*",
                "iam:GetPolicy",
                "cloudformation:*",
                "iam:ListRoles",
                "iam:DeleteRole",
                "iam:CreatePolicy",
                "iam:ListPolicyVersions",
                "ec2:*",
                "iam:UpdateRole",
                "eks:*",
                "iam:GetRolePolicy"
            ],
            "Resource": "*"
        }
    ]

}
POLICY
}*/
resource "aws_iam_role_policy_attachment" "ec2-read-only-policy-attachment" {
    role = "${aws_iam_role.group7.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"  
 }




/* resource "aws_iam_role_policy_attachment" "Group7-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.group7.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "Group7-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.group7.name
} */


resource "aws_instance" "Group7"{
    instance_type = "m5.xlarge"
    ami = "ami-045fa58af83eb0ff4"
    availability_zone = "us-east-2a"
    #instance_type = tolist(data.aws_ec2_instance_types.ami_instance.instance_types)[0]
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    
    tags = {
        Name = "terraform of group 7"
    }
}

resource "aws_security_group" "instance_sg" {
    name = "terraform-test-sg-group7"
    vpc_id = "aws_vpc.group7.id"

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


output "adresse_ip_instance" {
  value = aws_instance.Group7.public_ip
}

/*data "aws_ami" "ubuntu-ami"{
    owners = ["099720109477"]
    most_recent = true
    
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200408"]
    }
}

data "aws_ec2_instance_types" "ami_instance" {
    filter {
      name = "processor-info.supported-architecture"
      values = [data.aws_ami.ubuntu-ami.architecture]
    }
}*/

/*
module "website_s3_bucket" {
    source = "./modules/aws-s3-static-website-bucket"
    bucket_name = "group7-terraform-hackathon"
}
*/



















/*
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "Groupe7"

  ami                    = "ami-ebd02392"
  instance_type          = "m5.xlarge"
  key_name               = "groupe7"
  monitoring             = true
  vpc_security_group_ids = ["sg-12345678"]
  subnet_id              = "subnet-eddcdzz4"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}*/