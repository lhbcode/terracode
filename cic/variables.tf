variable "aws_region" {
  description = "The AWS region to use"
  default     = "ap-northeast-1"
}

locals {
  region           = var.aws_region
  instancetype     = "t2.micro"                     # 인스턴스 유형입니다.
  root_volume_size = 20                               # 디스크 사이즈 입니다.
  name             = "sk-test-infra"                            # 각 리소스에 붙일 이름입니다.
  cidr             = "10.98.0.0/16"                   # VPC생성시 사용할 네트워크 대역입니다.
  public_subnet            = ["10.98.1.0/24","10.98.2.0/24"] # 서브넷 대역 입니다. 위 cidr에 종속 적입니다.
  private_subnet           = ["10.98.3.0/24", "10.98.4.0/24","10.98.5.0/24"] # 서브넷 대역 입니다. 위 cidr에 종속 적입니다.
  database_subnets         = ["10.98.7.0/24", "10.98.8.0/24"]
  keyname_rsa      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7q3/zaue8esoxgX0rSx0M+qT7QqDcDcX5ewUtew5KkEI8vJ5V9XlLsUAI+hWAmOUXJGRZPwxCFOXxDi+9xPBnNVWuFa4gDNDS8wuWp4IVnlj59PFD1hXSOyekdGy2kae/BY3A0+kRchWT4nHmUXeCgcYFWsw04Q76ZNF7UI2tMO6Y6LlEO/KPxY9MbFSpLBouvKeQPXWYjzeLeIKnLXosZD07s17GLm6duc0R7qeRtgw+IJr1xPbwcZVurkH/0vIWEvN8nZ0Es29SVSTJJx1gSK5uqcRZfnTtWrDAGVs4kGHrPOlEBwR8UwC4GZhFlKrzzEsujs5f5uuT2Ax16cgQPYr/mOLgs6tI+MYpoZNrpwSuBVF7a9t9SJ+tHJY93XCPl7EhqiNkHhWs0TcRQGKET+F1cu92ZL2y7YTf5xJaUv3v9U4plz/mM84tsZ8HjR8cjja3PFmV5S5faHLSNucK8kCBi1L3QR4NtB093tgweQGgWDzpMS8Vpm2Spq6sIts= tom.hong@tomhongui-MacBookPro.local"
  # tom-key.pem 의 대응 공개키 입니다.
  user_data = <<-EOT
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0
--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"
#cloud-config
cloud_final_modules:
- [scripts-user, always]
--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"
#!/bin/bash
sudo apt update -y 
sudo apt install ruby-full -y
sudo apt install wget -y 
cd /home/ubuntu
wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
sudo chmod +x ./install
 ./install auto
 --//
EOT
}

variable "aws_amis" {
  description = "The AMI to use for setting up the instances."
  default = {
    # Ubuntu Xenial 20.04 LTS
    us-east-1      = "ami-042e8287309f5df03"
    us-east-2      = ""
    us-west-1      = ""
    us-west-2      = ""
    ap-south-1     = ""
    ap-northeast-1 = "ami-0fe22bffdec36361c"
    ap-northeast-2 = "ami-04876f29fd3a5e8ba"
    ap-southeast-1 = ""
    ap-southeast-2 = ""
    ca-central-1   = ""
    eu-central-1   = ""
    eu-west-1      = ""
    eu-west-2      = ""
    eu-west-3      = ""
    eu-north-1     = ""
    sa-east-1      = ""
  }
}