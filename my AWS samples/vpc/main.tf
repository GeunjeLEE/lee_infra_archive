provider "aws" {
	region = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "name"
  cidr                 = "172.31.0.0/16"

  azs		           = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets       = ["172.31.32.0/20"]

  enable_nat_gateway   = false
  single_nat_gateway   = false

  enable_dns_hostnames = true

	tags = {
		"Terraform" = "true"
	}

	public_subnet_tags = {
		"Terraform" = "true"
  }

}
