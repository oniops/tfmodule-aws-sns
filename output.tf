output "id" {
  value = try(aws_sns_topic.this[0].id, "")
}

output "arn" {
  value = "arn:aws:sns:${local.region}:${local.account_id}:${local.topic_name}"
}
