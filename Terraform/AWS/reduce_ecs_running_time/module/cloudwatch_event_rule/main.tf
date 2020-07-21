resource "aws_cloudwatch_event_rule" "this" {
  name                  = var.event_rule_name
  description           = "trigger for reduce ecs running time"

  # JST 07:00 ~ 18:00
  schedule_expression   = "cron(0 22,09 * * ? *)"
}

resource "aws_cloudwatch_event_target" "this" {
  target_id = "SendToLambda"
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = var.target_lambda_arn
}
