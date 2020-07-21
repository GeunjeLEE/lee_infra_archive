module "SoftEtherVPN_VPC" {
    source              = "./module/vpc"
}

module "SoftEtherVPN_HOST" {
    source              = "./module/ec2"
    subnet_id           = module.SoftEtherVPN_VPC.subnet_id
    sg_id               = module.SoftEtherVPN_VPC.sg_id
}