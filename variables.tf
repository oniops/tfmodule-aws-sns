variable "create" {
  description = "Determines whether resources will be created"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the SNS topic to create. It is formatted as '{name_prefix}-{name}-topic' (or '.fifo' suffix for FIFO topics)"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_-]+$", var.name))
    error_message = "The name can only contain alphanumeric characters, hyphens (-) and underscores (_)."
  }
}

variable "application_feedback" {
  type = object({
    failure_role_arn    = optional(string)
    success_role_arn    = optional(string)
    success_sample_rate = optional(number)
  })
  default     = {}
  description = <<EOF
IAM role ARNs and sample rate(0 ~ 100) for success and failure feedback

Ex)
  application_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF

  validation {
    condition     = var.application_feedback.success_sample_rate == null ? true : var.application_feedback.success_sample_rate >= 0 && var.application_feedback.success_sample_rate <= 100
    error_message = "success_sample_rate must be between 0 and 100."
  }
}

variable "content_based_deduplication" {
  description = "Boolean indicating whether or not to enable content-based deduplication for FIFO topics."
  type        = bool
  default     = false
}

variable "delivery_policy" {
  type        = any
  default     = null
  description = <<EOF
The SNS delivery policy as an object. A JSON string (e.g. jsonencode(...)) is also accepted.
If not set, templates/delivery-policy.tftpl is applied as the default delivery policy.
It is ignored for FIFO topics. (The delivery policy is always disabled for FIFO topics)
see - https://docs.aws.amazon.com/sns/latest/dg/DeliveryPolicies.html

Ex)
  delivery_policy = {
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 30,
        "maxDelayTarget" : 30,
        "numRetries" : 2,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  }
EOF

  validation {
    condition     = var.delivery_policy == null ? true : can(tostring(var.delivery_policy)) ? can(keys(jsondecode(var.delivery_policy))) : can(keys(var.delivery_policy))
    error_message = "delivery_policy must be an object or a valid JSON string."
  }
}

variable "archive_policy" {
  type        = string
  default     = null
  description = <<EOF
The message archive policy for FIFO topics.
see - https://docs.aws.amazon.com/sns/latest/dg/message-archiving-and-replay-topic-owner.html

Ex)
  archive_policy = jsonencode({
    "MessageRetentionPeriod" : 30
  })
EOF
}

variable "data_protection_policy" {
  type        = string
  default     = null
  description = <<EOF
An externally created fully-formed data protection policy as JSON for standard topics. (FIFO topics are not supported)
see - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_data_protection_policy

Ex)
  data_protection_policy = jsonencode({
    "Description" = "Example data protection policy"
    "Name"        = "__example_data_protection_policy"
    "Statement"   = [
      {
        "Sid"            = "__deny_statement_11ba9d96"
        "DataDirection"  = "Inbound"
        "DataIdentifier" = [
          "arn:aws:dataprotection::aws:data-identifier/EmailAddress",
        ]
        "Operation" = {
          "Deny" = {}
        }
        "Principal" = ["*",]
      }
    ]
    "Version" = "2021-06-01"
  })
EOF
}

variable "display_name" {
  description = "The display name for the SNS topic"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Boolean indicating whether or not to create a FIFO (first-in-first-out) topic"
  type        = bool
  default     = false
}

variable "fifo_throughput_scope" {
  description = "Enables higher throughput for FIFO topics by adjusting the scope of deduplication. Valid values are Topic, MessageGroup."
  type        = string
  default     = null

  validation {
    condition     = var.fifo_throughput_scope == null ? true : contains(["Topic", "MessageGroup"], var.fifo_throughput_scope)
    error_message = "fifo_throughput_scope must be one of Topic, MessageGroup."
  }
}

variable "signature_version" {
  type        = number
  default     = null
  description = <<EOF
If SignatureVersion should be 1 (SHA1) or 2 (SHA256).
The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS.

Ex)
  signature_version = 2
EOF

  validation {
    condition     = var.signature_version == null ? true : contains([1, 2], var.signature_version)
    error_message = "signature_version must be 1 or 2."
  }
}

variable "tracing_config" {
  description = "Tracing mode of an Amazon SNS topic. Valid values are PassThrough, Active."
  type        = string
  default     = null

  validation {
    condition     = var.tracing_config == null ? true : contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "tracing_config must be one of PassThrough, Active."
  }
}

variable "firehose_feedback" {
  type = object({
    failure_role_arn    = optional(string)
    success_role_arn    = optional(string)
    success_sample_rate = optional(number)
  })
  default     = {}
  description = <<EOF
IAM role ARNs and sample rate(0 ~ 100) for success and failure feedback

Ex)
  firehose_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF

  validation {
    condition     = var.firehose_feedback.success_sample_rate == null ? true : var.firehose_feedback.success_sample_rate >= 0 && var.firehose_feedback.success_sample_rate <= 100
    error_message = "success_sample_rate must be between 0 and 100."
  }
}

variable "http_feedback" {
  type = object({
    failure_role_arn    = optional(string)
    success_role_arn    = optional(string)
    success_sample_rate = optional(number)
  })
  default     = {}
  description = <<EOF
IAM role ARNs and sample rate(0 ~ 100) for success and failure feedback

Ex)
  http_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF

  validation {
    condition     = var.http_feedback.success_sample_rate == null ? true : var.http_feedback.success_sample_rate >= 0 && var.http_feedback.success_sample_rate <= 100
    error_message = "success_sample_rate must be between 0 and 100."
  }
}

variable "lambda_feedback" {
  type = object({
    failure_role_arn    = optional(string)
    success_role_arn    = optional(string)
    success_sample_rate = optional(number)
  })
  default     = {}
  description = <<EOF
IAM role ARNs and sample rate(0 ~ 100) for success and failure feedback

Ex)
  lambda_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF

  validation {
    condition     = var.lambda_feedback.success_sample_rate == null ? true : var.lambda_feedback.success_sample_rate >= 0 && var.lambda_feedback.success_sample_rate <= 100
    error_message = "success_sample_rate must be between 0 and 100."
  }
}

variable "sqs_feedback" {
  type = object({
    failure_role_arn    = optional(string)
    success_role_arn    = optional(string)
    success_sample_rate = optional(number)
  })
  default     = {}
  description = <<EOF
IAM role ARNs and sample rate(0 ~ 100) for success and failure feedback

Ex)
  sqs_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF

  validation {
    condition     = var.sqs_feedback.success_sample_rate == null ? true : var.sqs_feedback.success_sample_rate >= 0 && var.sqs_feedback.success_sample_rate <= 100
    error_message = "success_sample_rate must be between 0 and 100."
  }
}

variable "kms_key_arn" {
  description = <<EOF
The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK. (alias, key ID, or ARN)
Encryption at rest is strongly recommended.
Note that AWS services such as CloudWatch Alarms, EventBridge and S3 cannot publish to a topic encrypted with "alias/aws/sns", use a custom CMK instead.
EOF
  type        = string
  default     = null
}

# Subscriptions
variable "subscriptions" {
  type = map(object({
    protocol                        = string
    endpoint                        = string
    endpoint_auto_confirms          = optional(bool)
    raw_message_delivery            = optional(bool, false)
    filter_policy                   = optional(string)
    filter_policy_scope             = optional(string)
    redrive_policy                  = optional(string)
    replay_policy                   = optional(string)
    delivery_policy                 = optional(string)
    subscription_role_arn           = optional(string)
    confirmation_timeout_in_minutes = optional(number, 1)
  }))
  default     = {}
  description = <<EOF
Map of subscriptions who received message from SNS Topic. The map key is used as a stable identifier of the subscription.

Valid subscription protocols are sqs, sms, lambda, firehose, and application.
Protocols email, email-json, http and https are also valid but partially supported.

In case of firehose protocol, It should require subscription_role_arn.

Ex)
  subscriptions = {
    master_mail = {
      protocol = "email"
      endpoint = "master@company.com"
    }
    no_reply_mail = {
      protocol                        = "email"
      endpoint                        = "no-reply@company.com"
      confirmation_timeout_in_minutes = 10
    }
    apple_sqs = {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:ap-northeast-2:111122223333:my-company-apple-sqs"
    }
    banana_sqs = {
      protocol             = "sqs"
      endpoint             = "arn:aws:sqs:ap-northeast-2:111122223333:my-company-banana-sqs"
      raw_message_delivery = true
      filter_policy = jsonencode({
        event_type = ["order_placed", "order_shipped"]
      })
    }
    melon_sqs = {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:ap-northeast-2:111122223333:my-company-melon-sqs"
      replay_policy = jsonencode({
        "PointType"     = "Timestamp"
        "StartingPoint" = "2026-01-01T00:00:00Z"
      })
    }
    webhook = {
      protocol = "https"
      endpoint = "https://example.com/webhook"
      delivery_policy = jsonencode({
        healthyRetryPolicy = {
          minDelayTarget     = 1
          maxDelayTarget     = 60
          numRetries         = 50
          numNoDelayRetries  = 3
          numMinDelayRetries = 2
          numMaxDelayRetries = 35
          backoffFunction    = "exponential"
        }
        throttlePolicy = {
          maxReceivesPerSecond = 10
        }
        requestPolicy = {
          headerContentType = "application/json"
        }
      })
    }
  }
EOF
}

variable "create_topic_policy" {
  description = "Determines whether an SNS topic policy is created"
  type        = bool
  default     = true
}

variable "access_policy" {
  type        = any
  default     = null
  description = <<EOF
List of IAM policy statements for the SNS topic access policy.
It replaces the default access policy(templates/access-policy.tftpl) entirely, so include every statement the topic needs.
Each statement must have a unique `Sid`.
If `Resource` and `NotResource` are omitted in a statement, the ARN of this topic is used as `Resource`.
If not set, templates/access-policy.tftpl is applied as the default access policy.
see - https://docs.aws.amazon.com/sns/latest/dg/sns-access-policy-use-cases.html

Ex)
  access_policy = [
    {
      "Sid" : "AllowDefaultAccess",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::111122223333:root"
      },
      "Action" : [
        "sns:Publish",
        "sns:Subscribe",
        "sns:GetTopicAttributes",
        "sns:SetTopicAttributes",
        "sns:ListSubscriptionsByTopic",
        "sns:AddPermission",
        "sns:RemovePermission",
        "sns:DeleteTopic"
      ]
    },
    {
      "Sid" : "AllowEventBridgePublish",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "events.amazonaws.com"
      },
      "Action" : "SNS:Publish",
      "Condition" : {
        "ArnEquals" : {
          "aws:SourceArn" : "arn:aws:events:ap-northeast-2:111122223333:rule/dev-ecs-task-stopped-rule"
        }
      }
    }
  ]
EOF

  validation {
    condition = var.access_policy == null ? true : try(length(var.access_policy) > 0 && alltrue([
      for s in var.access_policy :
      contains(["Allow", "Deny"], s.Effect) && (can(s.Principal) || can(s.NotPrincipal)) && (can(s.Action) || can(s.NotAction))
    ]), false)
    error_message = "access_policy must be a non-empty list of policy statements, and each statement must have an Effect(Allow or Deny), Principal(or NotPrincipal) and Action(or NotAction)."
  }

  validation {
    condition = var.access_policy == null ? true : try(
      alltrue([for s in var.access_policy : length(trimspace(tostring(s.Sid))) > 0]) &&
      length(distinct([for s in var.access_policy : s.Sid])) == length(var.access_policy),
      false
    )
    error_message = "Each statement of access_policy must have a non-empty Sid, and Sids must be unique."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
