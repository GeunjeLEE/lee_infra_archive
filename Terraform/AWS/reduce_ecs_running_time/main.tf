module "ecs_running_time_lambda"{
    source                    = "./module/lambda"
    func_name                 = var.func_name
    lambda_trigger_source_arn = module.cloudwatch_event_rule_for_redute_ecs_running_time.cloudwatch_event_rule_arn
}

module "cloudwatch_event_rule_for_redute_ecs_running_time"{
    source              = "./module/cloudwatch_event_rule"
    event_rule_name     = var.event_rule_name
    target_lambda_arn   = module.ecs_running_time_lambda.lambda_func_arn
}
