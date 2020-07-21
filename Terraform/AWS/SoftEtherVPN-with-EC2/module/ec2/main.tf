resource "aws_instance" "this" {
    ami                    = "ami-06ad9296e6cf1e3cf"
    vpc_security_group_ids = [var.sg_id]
    subnet_id              = var.subnet_id
    instance_type          = "t2.micro"
    iam_instance_profile   = aws_iam_role.this.name
    user_data = file("./install_softehtervpn.sh")

    tags = {
        Name = "softetherVPN_host"
    }
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  vpc      = true
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

