output "vpc_id" {
    value = aws_vpc.this.id
}

output "subnet_id" {
    value = aws_subnet.this.id
}

output "sg_id" {
    value = aws_security_group.this.id
}