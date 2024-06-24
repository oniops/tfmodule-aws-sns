locals {
  account_id  = var.context.account_id
  region      = var.context.region
  name_prefix = var.context.name_prefix
  topic_name  = format("%s-%s-topic", local.name_prefix, var.name)
  tags        = var.context.tags
}

resource "aws_sns_topic" "this" {
  count = var.create ? 1 : 0

  name = local.topic_name

  content_based_deduplication = var.content_based_deduplication

  display_name      = var.display_name
  fifo_topic        = var.fifo_topic
  signature_version = var.fifo_topic ? null : var.signature_version
  tracing_config    = var.tracing_config
  kms_master_key_id = var.kms_key_arn
  # policy            = var.policy # Use aws_sns_topic_policy
  delivery_policy   = var.delivery_policy
  archive_policy    = var.archive_policy

  # Configuration for feedbacks
  application_failure_feedback_role_arn    = lookup(var.application_feedback, "failure_role_arn", null)
  application_success_feedback_role_arn    = lookup(var.application_feedback, "success_role_arn", null)
  application_success_feedback_sample_rate = lookup(var.application_feedback, "success_sample_rate", null)
  #
  firehose_failure_feedback_role_arn       = lookup(var.firehose_feedback, "failure_role_arn", null)
  firehose_success_feedback_role_arn       = lookup(var.firehose_feedback, "success_role_arn", null)
  firehose_success_feedback_sample_rate    = lookup(var.firehose_feedback, "success_sample_rate", null)
  #
  http_failure_feedback_role_arn           = lookup(var.http_feedback, "failure_role_arn", null)
  http_success_feedback_role_arn           = lookup(var.http_feedback, "success_role_arn", null)
  http_success_feedback_sample_rate        = lookup(var.http_feedback, "success_sample_rate", null)
  #
  lambda_failure_feedback_role_arn         = lookup(var.lambda_feedback, "failure_role_arn", null)
  lambda_success_feedback_role_arn         = lookup(var.lambda_feedback, "success_role_arn", null)
  lambda_success_feedback_sample_rate      = lookup(var.lambda_feedback, "success_sample_rate", null)
  #
  sqs_failure_feedback_role_arn            = lookup(var.sqs_feedback, "failure_role_arn", null)
  sqs_success_feedback_role_arn            = lookup(var.sqs_feedback, "success_role_arn", null)
  sqs_success_feedback_sample_rate         = lookup(var.sqs_feedback, "success_sample_rate", null)


  tags = merge(local.tags, var.tags, {
    Name = local.topic_name
  })
}

resource "aws_sns_topic_policy" "this" {
  count  = var.create && var.policy != null ? 1 : 0
  arn    = aws_sns_topic.this[0].arn
  policy = var.policy
}

################################################################################
# Data Protection Policy
################################################################################

resource "aws_sns_topic_data_protection_policy" "this" {
  count  = var.create && var.data_protection_policy != null && !var.fifo_topic ? 1 : 0
  arn    = aws_sns_topic.this[0].arn
  policy = var.data_protection_policy
}