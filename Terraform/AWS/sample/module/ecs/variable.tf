variable "vpc_id" {
    default = ""
}

variable "subnets" {
    type    = list(string)
    default = []
}

variable "lb_target_group" {
    default = ""
}

variable "alb_sg" {
    default = ""
}