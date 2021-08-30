################################################################################
# LB 생성 
################################################################################

# LB 서브넷 구성을 위한 데이터 필터(서브넷ID)
data "aws_subnet_ids" "private" {
  vpc_id = module.vpc.vpc_id 

   filter {
    name   = "tag:Name"
    values = ["${local.name}-vpc-private-${local.region}c"] # insert values here
  }

}

# NLB 생성 
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true 
  load_balancer_type = "network"
  subnets            = data.aws_subnet_ids.private.ids

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

# NLB 타켓 그룹 생성 
resource "aws_lb_target_group" "test" {
  name         = "tf-example-lb-tg"
  port         = 81
  protocol     = "TCP"
  target_type = "instance" 
  vpc_id       = module.vpc.vpc_id
}

# NLB 타켓 그룹에 대한 리스너 생성 
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}

# NLB 생성된 인스턴스 타겟 그룹 추가 
# ec2 생성까지 종속 관계 유지  
resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = "${element(module.ec2_back.id,0)}"
  port             = 81

  depends_on = [
    module.ec2_back
  ]
}

