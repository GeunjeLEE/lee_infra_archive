resource "aws_instance" "this" {
    ami                    = "ami-0094965d55b3bb1ff"
    vpc_security_group_ids = [aws_security_group.this.id]
    subnet_id              = var.subnet_id
    instance_type          = "t2.micro"
    iam_instance_profile   = aws_iam_role.this.name
    availability_zone      = "ap-northeast-2c"

    tags = {
        Name = "mysql_host"
    }
}

resource "aws_iam_instance_profile" "this" {
    name = "ssm_role_for_ec2"
    role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
    name = "ssm_role_for_ec2"

    assume_role_policy = <<EOF
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
}

resource "aws_iam_role_policy_attachment" "this" {
    role       = aws_iam_role.this.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "this" {
  name        = "sg_for_mysql"
  description = "Allow 3306 inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "mysql port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
