data "aws_partition" "current" {}

locals {
  account_id  = var.context.account_id
  name_prefix = var.context.name_prefix
  topic_name  = var.fifo_topic ? "${local.name_prefix}-${var.name}-topic.fifo" : "${local.name_prefix}-${var.name}-topic"
  tags        = var.context.tags
}

resource "aws_sns_topic" "this" {
  count = var.create ? 1 : 0

  name = local.topic_name

  content_based_deduplication = var.content_based_deduplication

  display_name          = var.display_name
  fifo_topic            = var.fifo_topic
  fifo_throughput_scope = var.fifo_throughput_scope
  signature_version     = var.signature_version
  tracing_config        = var.tracing_config
  kms_master_key_id     = var.kms_key_arn
  # templates/delivery-policy.tftpl is used as the default delivery policy when `delivery_policy` is not set.
  # The delivery policy is always disabled for FIFO topics.
  delivery_policy = var.fifo_topic ? null : (
    var.delivery_policy == null ? templatefile("${path.module}/templates/delivery-policy.tftpl", {}) : try(tostring(var.delivery_policy), jsonencode(var.delivery_policy))
  )
  archive_policy = var.archive_policy

  # Configuration for feedbacks
  application_failure_feedback_role_arn    = var.application_feedback.failure_role_arn
  application_success_feedback_role_arn    = var.application_feedback.success_role_arn
  application_success_feedback_sample_rate = var.application_feedback.success_sample_rate
  #
  firehose_failure_feedback_role_arn    = var.firehose_feedback.failure_role_arn
  firehose_success_feedback_role_arn    = var.firehose_feedback.success_role_arn
  firehose_success_feedback_sample_rate = var.firehose_feedback.success_sample_rate
  #
  http_failure_feedback_role_arn    = var.http_feedback.failure_role_arn
  http_success_feedback_role_arn    = var.http_feedback.success_role_arn
  http_success_feedback_sample_rate = var.http_feedback.success_sample_rate
  #
  lambda_failure_feedback_role_arn    = var.lambda_feedback.failure_role_arn
  lambda_success_feedback_role_arn    = var.lambda_feedback.success_role_arn
  lambda_success_feedback_sample_rate = var.lambda_feedback.success_sample_rate
  #
  sqs_failure_feedback_role_arn    = var.sqs_feedback.failure_role_arn
  sqs_success_feedback_role_arn    = var.sqs_feedback.success_role_arn
  sqs_success_feedback_sample_rate = var.sqs_feedback.success_sample_rate

  tags = merge(local.tags, var.tags, {
    Name = local.topic_name
  })

  lifecycle {
    precondition {
      condition     = data.aws_partition.current.partition == "aws"
      error_message = "This module only supports the AWS public partition (aws). Current partition is '${data.aws_partition.current.partition}'."
    }
    precondition {
      condition     = length(local.topic_name) <= 256
      error_message = "The topic name '${local.topic_name}' exceeds 256 characters."
    }
    precondition {
      condition     = var.fifo_topic || (!var.content_based_deduplication && var.archive_policy == null && var.fifo_throughput_scope == null)
      error_message = "content_based_deduplication, archive_policy and fifo_throughput_scope are only supported for FIFO topics."
    }
    precondition {
      condition     = !(var.fifo_topic && var.data_protection_policy != null)
      error_message = "data_protection_policy is not supported for FIFO topics."
    }
  }
}

################################################################################
# Data Protection Policy
################################################################################

resource "aws_sns_topic_data_protection_policy" "this" {
  count = var.create && var.data_protection_policy != null ? 1 : 0

  arn    = aws_sns_topic.this[0].arn
  policy = var.data_protection_policy
}
