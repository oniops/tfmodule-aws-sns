output "id" {
  description = "The ID of the SNS topic"
  value = try(aws_sns_topic.this[0].id, null)
}

output "arn" {
  description = "The ARN of the SNS topic"
  value = try(aws_sns_topic.this[0].arn, null)
}

output "name" {
  description = "The name of the SNS topic"
  value = try(aws_sns_topic.this[0].name, null)
}

output "owner" {
  description = "The AWS Account ID of the SNS topic owner"
  value = try(aws_sns_topic.this[0].owner, null)
}

output "subscriptions" {
  description = "Map of subscription keys to their ARNs"
  value       = {for k, v in aws_sns_topic_subscription.this : k => v.arn}
}

output "access_policy" {
  description = "The fully-formed AWS policy as JSON attached to the SNS topic"
  value = try(aws_sns_topic_policy.this[0].policy, null)
}

output "delivery_policy" {
  description = "The fully-formed AWS policy as JSON attached to the SNS topic"
  value = try(aws_sns_topic.this[0].delivery_policy, null)
}
