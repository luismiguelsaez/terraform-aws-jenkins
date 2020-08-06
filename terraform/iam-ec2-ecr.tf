resource "aws_iam_role" "main" {
  name = format("%s-ec2",local.environment)

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF

  tags = {
    environment = local.environment
  }
}

### ECR actions reference: https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonelasticcontainerregistry.html
resource "aws_iam_role_policy" "main" {
  name = format("%s-ec2",local.environment)
  role = aws_iam_role.main.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ecr:GetAuthorizationToken"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRepositories"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/*"
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "main" {
  name = format("%s-ec2",local.environment)
  role = aws_iam_role.main.id
}