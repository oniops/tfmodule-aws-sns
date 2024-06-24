variable "create" {
  type    = bool
  default = true
}

variable "name" {
  description = "The name of the SNS topic to create"
  type        = string
}

variable "policy" {
  type        = string
  default     = null
  description = <<EOF
An externally created fully-formed AWS policy as JSON

Ex)
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
        }
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.example.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_sqs_queue.example.arn
          }
        }
      }
    ]
  })
EOF
}

variable "application_feedback" {
  type        = map(string)
  default     = {}
  description = <<EOF
Map of IAM role ARNs and sample rate for success and failure feedback

Ex)
  application_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF
}

variable "content_based_deduplication" {
  description = "Boolean indicating whether or not to enable content-based deduplication for FIFO topics."
  type        = bool
  default     = false
}

variable "delivery_policy" {

  type        = string
  default     = null
  description = <<EOF
The SNS delivery policy
see - https://docs.aws.amazon.com/sns/latest/dg/DeliveryPolicies.html

Ex)
  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false,
      "defaultThrottlePolicy" : {
        "maxReceivesPerSecond" : 1
      }
    }
  })
EOF
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
The message archive policy for FIFO topics.
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

variable "signature_version" {
  type        = number
  default     = null
  description = <<EOF
If SignatureVersion should be 1 (SHA1) or 2 (SHA256).
The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS.

Ex)
  signature_version = 2
EOF
}

variable "tracing_config" {
  description = "Tracing mode of an Amazon SNS topic. Valid values are PassThrough, Active."
  type        = string
  default     = null
}

variable "firehose_feedback" {
  type        = map(string)
  default     = {}
  description = <<EOF
Map of IAM role ARNs and sample rate for success and failure feedback

Ex)
  firehose_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF
}


variable "http_feedback" {
  type        = map(string)
  default     = {}
  description = <<EOF
Map of IAM role ARNs and sample rate for success and failure feedback

Ex)
  http_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF
}

variable "lambda_feedback" {
  type        = map(string)
  default     = {}
  description = <<EOF
Map of IAM role ARNs and sample rate for success and failure feedback

Ex)
  lambda_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF
}

variable "sqs_feedback" {
  type        = map(string)
  default     = {}
  description = <<EOF
Map of IAM role ARNs and sample rate for success and failure feedback

Ex)
  sqs_feedback = {
    failure_role_arn    = "arn:aws:iam::11111111111:role/failure"
    success_role_arn    = "arn:aws:iam::11111111111:role/success"
    success_sample_rate = 75
  }
EOF
}

variable "kms_key_arn" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SNS or a custom CMK."
  type        = string
  default     = null
}

# Subscriptions
variable "subscriptions" {
  type    = list(any)
  default = []
  description = <<EOF
Add subscriptions who received message from SNS Topic.

Valid subscription protocols are sqs, sms, lambda, firehose, and application.
Protocols email, email-json, http and https are also valid but partially supported.

In case of firehose protocol, It should require subscription_role_arn.

Ex)
  subscriptions = [
    {
      protocol = "email"
      endpoint = "master@company.com
    },
    {
      protocol = "email"
      endpoint = "no-reply@company.com
    },
    {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:ap-northeast-2:111122223333:my-company-apple-sqs"
    },
    {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:ap-northeast-2:111122223333:my-company-banana-sqs"
      raw_message_delivery = true
      filter_policy        = jsonencode({
        event_type = ["order_placed", "order_shipped"]
      })
    },
    {
      protocol = "sqs"
      endpoint = "arn:aws:sqs:ap-northeast-2:111122223333:my-company-melon-sqs"
      replay_policy = jsonencode({
        "PointType": "Timestamp"
        "StartingPoint": timestamp()
      })
    },
    {
      protocol = "http"
      endpoint = "https://example.com/webhook"
    }
  }
EOF
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
