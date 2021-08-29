provider "aws" {
  region = var.aws_region
}

#### 키 파일 생성 
resource "random_string" "random" {
  length  = 8
  special = false
}
module "keypair" {
  source = "../module/key-pair"

  key_name   = "${local.name}-key-${random_string.random.id}"
  public_key = local.keyname_rsa
}


#### vpc 생성 
module "vpc" {
  source = "../module/vpc"

  name = "${local.name}-vpc-${random_string.random.id}"
  cidr = local.cidr

  azs            = ["${local.region}a", "${local.region}c"]
  public_subnets = local.public_subnet
  private_subnets = local.private_subnet
  create_igw           = true
  enable_dhcp_options  = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway = true


  tags = {
    Owner       = "${local.name}"
    Environment = "dev"
  }
}

# 보안 그룹 생성 

module "security_group_ec2" {
  source = "../module/security-group"

  name        = "${local.name}-test-sg-${random_string.random.id}"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp", "ssh-tcp","http-80-tcp"]
  egress_rules        = ["all-all"]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.security_group_ec2.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
}

module "ec2_bastion" {
  source = "../module/ec2-instance"

  name           = "${local.name}-bastions-${random_string.random.id}"
  instance_count = 1

  ami           = lookup(var.aws_amis, var.aws_region)
  instance_type = local.instancetype
#   user_data     = data.template_file.user_data.rendered

  key_name             = module.keypair.key_pair_key_name
  monitoring           = true
#   iam_instance_profile = aws_iam_instance_profile.ccm_master_role.name

  vpc_security_group_ids = [module.security_group_ec2.security_group_id]

  subnet_id = module.vpc.public_subnets[0]

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = local.root_volume_size
    },
  ]
  tags = {
    Owner                       = "${local.name}"
  }
}
module "ec2_frontend" {
  source = "../module/ec2-instance"

  name           = "${local.name}-frontend-${random_string.random.id}"
  instance_count = 1

  ami           = lookup(var.aws_amis, var.aws_region)
  instance_type = local.instancetype
  user_data     = local.user_data

  key_name             = module.keypair.key_pair_key_name
  monitoring           = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [module.security_group_ec2.security_group_id]

  subnet_id = module.vpc.private_subnets[0]

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = local.root_volume_size
    },
  ]
  tags = {
    Owner                       = "${local.name}"
    Environment                 = "dev"
    "kubernetes.io/cluster/tom" = "owned"
  }
}
module "security_group_alb" {
  source = "../module/security-group"

  name        = "${local.name}-test-alb-sg-${random_string.random.id}"
  description = "Security group for example usage with ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}
module "security_group_alb2" {
  source = "../module/security-group"

  name        = "${local.name}-test-alb2-sg-${random_string.random.id}"
  description = "Security group for example usage with ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [ module.security_group_alb.security_group_id,module.security_group_alb2.security_group_id ]

#   access_logs = {
#     bucket = "my-alb-logs"
#   }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id =  "${element(module.ec2_frontend.id, 1)}"
          port = 80
        }
      ]
    }
  ]

#   https_listeners = [
#     {
#       port               = 443
#       protocol           = "HTTPS"
#       certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
#       target_group_index = 0
#     }
#   ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}