resource "aws_cloudwatch_event_rule" "this" {
  name        = var.event_rule_name
  description = "Amazon service health check"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ecr"
  ],
  "detail-type": [
    "ECR Image Scan"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "this" {
  target_id = "SendToLambda"
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = var.target_lambda_arn
}
