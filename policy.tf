################################################################################
# Topic Policy
################################################################################

resource "aws_sns_topic_policy" "this" {
  count = var.create && var.create_topic_policy ? 1 : 0

  arn = aws_sns_topic.this[0].arn
  # `access_policy` statements are applied as they are (Resource defaults to the topic ARN when omitted),
  # otherwise templates/access-policy.tftpl is used as the default access policy.
  policy = var.access_policy != null ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in var.access_policy :
      merge(can(statement.Resource) || can(statement.NotResource) ? {} : { Resource = aws_sns_topic.this[0].arn }, statement)
    ]
    }) : templatefile("${path.module}/templates/access-policy.tftpl", {
    account_id = local.account_id
    topic_arn  = aws_sns_topic.this[0].arn
  })
}

check "access_policy_without_topic_policy" {
  assert {
    condition     = !var.create || var.create_topic_policy || var.access_policy == null
    error_message = "access_policy is ignored because create_topic_policy is false."
  }
}
