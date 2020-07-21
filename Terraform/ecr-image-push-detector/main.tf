module "image_scan_lambda"{
    source              = "./module/lambda"
    func_name           = var.func_name
    slack_hook_url      = "Slack Webhook URL"
    source_arn          = module.cloudwatch_event_rule_for_ecr_scan.cloudwatch_event_rule_arn
}

module "cloudwatch_event_rule_for_ecr_scan"{
    source              = "./module/cloudwatch_event_rule"
    event_rule_name     = var.event_rule_name
    target_lambda_arn   = module.image_scan_lambda.lambda_func_arn
}
