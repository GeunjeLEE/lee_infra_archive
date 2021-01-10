module "VPC" {
    source              = "./module/vpc"
}

module "mysql_instance" {
    source              = "./module/ec2"
    vpc_id              = module.VPC.vpc_id
    subnet_id           = module.VPC.private_subnet_c_id
}

module "ecr" {
    source              = "./module/ecr"
}

module "alb" {
    source              = "./module/alb"
    vpc_id              = module.VPC.vpc_id
    subnets             = [module.VPC.public_subnet_b_id,module.VPC.public_subnet_c_id]
}

module "ecs" {
    source              = "./module/ecs"
    vpc_id              = module.VPC.vpc_id
    subnets             = [module.VPC.private_subnet_b_id,module.VPC.private_subnet_c_id]
    alb_sg              = module.alb.alb_sg_id
    lb_target_group     = module.alb.alb_target_arn
}