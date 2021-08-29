# for ec2 policy
resource "aws_iam_role" "ec2_role" {
  name               = "tom-test-cicd-role-ec2"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "EC2InstanceRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "tom-test-cicd-role-ec2"
  role = aws_iam_role.ec2_role.name
}

# for deploy policy
resource "aws_iam_role" "tom-test-cicd-role-cicd" {
  name               = "tom-test-cicd-role-cicd"
  path               = "/"
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


resource "aws_iam_role_policy_attachment" "tom-test-cicd-role-cicd" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.tom-test-cicd-role-cicd.name
}


# resource "aws_iam_instance_profile" "tom-test-cicd-role-cicd" {
#   name = "tom-test-cicd-role-cicd"
#   role = aws_iam_role.tom-test-cicd-role-cicd.name
# }
