resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.lambda_trigger_source_arn
}

resource "aws_lambda_function" "this" {
  filename      = "lambda_function.zip"
  function_name = var.func_name
  role          = aws_iam_role.this.arn
  handler       = "reduce_ecs_running_time.lambda_handler"

  source_code_hash = filebase64sha256("lambda_function.zip")

  runtime = "python3.8"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.func_name}"
  retention_in_days = 14
}

resource "aws_iam_role" "this" {
  name = "${var.func_name}_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "this" {
  name        = "${var.func_name}_policy"
  path        = "/"
  description = "IAM policy for ${var.func_name} lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ecs:DescribeServices",
            "ecs:UpdateService"
        ],
        "Resource": [
            "*"
        ]
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}