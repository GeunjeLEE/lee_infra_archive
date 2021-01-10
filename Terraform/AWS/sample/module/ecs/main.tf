resource "aws_ecs_cluster" "this" {
  name = "sample-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                      = "service"
  container_definitions       = file("./task-definitions/service.json")
  task_role_arn               = "arn:aws:iam::547961105129:role/ecsTaskExecutionRole"
  execution_role_arn          = "arn:aws:iam::547961105129:role/ecsTaskExecutionRole"
  network_mode                = "awsvpc"
  requires_compatibilities    = ["FARGATE"]
  cpu                         = 256
  memory                      = 512
}

resource "aws_ecs_service" "this" {
  name              = "sample-node-service"
  cluster           = aws_ecs_cluster.this.id
  task_definition   = aws_ecs_task_definition.this.arn
  desired_count     = 1
  launch_type       = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.this.id]
  }

  load_balancer {
    target_group_arn = var.lb_target_group
    container_name   = "node"
    container_port   = 3000
  }
}

resource "aws_security_group" "this" {
  name        = "sg_for_ecs"
  description = "Allow ecs inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [var.alb_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
