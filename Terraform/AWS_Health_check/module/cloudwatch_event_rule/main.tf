resource "aws_cloudwatch_event_rule" "this" {
  name        = "aws_service_health_rule"
  description = "Amazon service health check"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.health"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = "${aws_cloudwatch_event_rule.this.name}"
  target_id = "SendToSNS"
  arn       = "${aws_sns_topic.aws_logins.arn}" //reference to remote tfstate
}