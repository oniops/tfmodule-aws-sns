resource "aws_sns_topic_subscription" "this" {
  for_each = var.create ? var.subscriptions : {}

  topic_arn                       = aws_sns_topic.this[0].arn
  protocol                        = each.value.protocol
  endpoint                        = each.value.endpoint
  endpoint_auto_confirms          = each.value.endpoint_auto_confirms
  raw_message_delivery            = each.value.raw_message_delivery
  filter_policy                   = each.value.filter_policy
  filter_policy_scope             = each.value.filter_policy_scope
  redrive_policy                  = each.value.redrive_policy
  replay_policy                   = each.value.replay_policy
  delivery_policy                 = each.value.delivery_policy
  subscription_role_arn           = each.value.subscription_role_arn
  confirmation_timeout_in_minutes = each.value.confirmation_timeout_in_minutes
}
