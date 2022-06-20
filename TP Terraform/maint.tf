provider "aws" {
    region = var.AWS_REGION
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY 
    instance_type = var.type_instance
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

  config_path    = "~/.kube/config" 

}   

resource "aws_eks_cluster" "group7" {
  name     = "group7"
  role_arn = aws_iam_role.group7.arn

  vpc_config {
    name = "terraform-test-sg-group7"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.group7-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.group7-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.group7.endpoint
}

/*output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.example.certificate_authority[0].data
}
*/
resource "aws_eks_node_group" "group7" {
  cluster_name    = aws_eks_cluster.group7
  node_group_name = "Group7"
  node_role_arn   = aws_iam_role.group7.arn
  subnet_ids      = aws_subnet.group7[*].id

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
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}
resource "aws_instance" "Group7"{
    ami = data.aws_ami.ubuntu-ami.id
    instance_type = tolist(data.aws_ec2_instance_types.ami_instance.instance_types)[0]
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    
    tags = {
        Name = "terraform of group 7"
    }
}

resource "aws_security_group" "instance_sg" {
    name = "terraform-test-sg-group7"

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
  value = aws_instance.my_ec2_instance.public_ip
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


module "website_s3_bucket" {
    source = "./modules/aws-s3-static-website-bucket"
    bucket_name = "group7-terraform-hackathon"
}
