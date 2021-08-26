resource "aws_codecommit_repository" "code_cre" {
  repository_name        = "lhb-test"
  description            = "test"
  default_branch         = "master"

}

# code deploy 
resource "aws_iam_role" "example" {
  name = "example-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.example.name
}

resource "aws_codedeploy_app" "example" {
  name = "example-app"
  compute_platform = "Server"
}


resource "aws_codedeploy_deployment_group" "example" {
  app_name              = aws_codedeploy_app.example.name
  deployment_group_name = "example-group"
  service_role_arn      = aws_iam_role.example.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "test-code-deploy"
    }
  }
}