resource "aws_sns_topic_subscription" "this" {
  for_each = {for k, v in var.subscriptions : k => v if var.create}

  topic_arn                       = aws_sns_topic.this[0].arn
  protocol                        = lookup(each.value, "protocol")
  endpoint                        = lookup(each.value, "endpoint")
  endpoint_auto_confirms          = lookup(each.value, "endpoint_auto_confirms", null)
  raw_message_delivery            = lookup(each.value, "raw_message_delivery", false)
  filter_policy                   = lookup(each.value, "filter_policy", null)
  filter_policy_scope             = lookup(each.value, "filter_policy_scope", null)
  redrive_policy                  = lookup(each.value, "redrive_policy", null)
  replay_policy                   = lookup(each.value, "replay_policy", null)
  delivery_policy                 = lookup(each.value, "delivery_policy", null)
  subscription_role_arn           = lookup(each.value, "subscription_role_arn", null)
  confirmation_timeout_in_minutes = lookup(each.value, "confirmation_timeout_in_minutes", 1)
}
