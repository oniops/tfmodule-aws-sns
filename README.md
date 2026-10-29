# tfmodule-aws-sns

AWS SNS 토픽을 생성 하는 테라폼 모듈 입니다.

## Usage

```hcl
data "aws_kms_alias" "main" {
  name = "alias/example-main-kms"
}

data "aws_sqs_queue" "event" {
  name = "example-event-sqs"
}

module "ctx" {
  source = "git::https://github.com/oniops/tfmodule-context.git?ref=v1.3.6"
  context = {
    project     = "example"
    region      = "ap-northeast-2"
    environment = "Development"
    owner       = "example@opsnow.com"
    department  = "DevOps"
    customer    = "Example Corp."
    domain      = "example.com"
    pri_domain  = "example.local"
  }
}

# The topic is encrypted with a custom CMK. Its key policy must allow kms:GenerateDataKey* and kms:Decrypt
# to the publishers (e.g. events.amazonaws.com). If the SQS queue is encrypted with a CMK,
# its key policy must also allow them to sns.amazonaws.com.
module "demo" {
  source      = "git::https://github.com/oniops/tfmodule-aws-sns.git?ref=v1.1.0"
  context     = module.ctx.context
  name        = "demo"
  kms_key_arn = data.aws_kms_alias.main.arn

  # access_policy replaces the default access policy(templates/access-policy.tftpl) entirely.
  # Resource defaults to the ARN of this topic when Resource and NotResource are omitted.
  access_policy = [
    {
      "Sid" : "AllowDefaultAccess",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${module.ctx.account_id}:root"
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
      "Sid" : "DenyInsecureTransport",
      "Effect" : "Deny",
      "Principal" : {
        "AWS" : "*"
      },
      "Action" : "sns:Publish",
      "Condition" : {
        "Bool" : {
          "aws:SecureTransport" : "false"
        }
      }
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
          "aws:SourceArn" : "arn:aws:events:${module.ctx.region}:${module.ctx.account_id}:rule/example-ecs-task-stopped-rule"
        }
      }
    }
  ]

  # templates/delivery-policy.tftpl is applied when delivery_policy is not set. (Ignored for FIFO topics)
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

  # The map key is used as a stable identifier of the subscription.
  # The SQS queue policy must allow sqs:SendMessage from sns.amazonaws.com for this topic.
  subscriptions = {
    apple_mail = {
      protocol = "email"
      endpoint = "apple@company.com"
    }
    banana_mail = {
      protocol = "email"
      endpoint = "banana@company.com"
    }
    event_sqs = {
      protocol = "sqs"
      endpoint = data.aws_sqs_queue.event.arn
    }
  }
}
```

## Input Variables

| Name | Description | Type | Example | Required |
|------|-------------|------|---------|:--------:|
| `context` | Context from tfmodule-context (account_id, region, name_prefix, tags, ...) | `object` | `module.ctx.context` | yes |
| `name` | Topic name. Created as `{name_prefix}-{name}-topic` (`.fifo` suffix for FIFO topics) | `string` | `"demo"` | yes |
| `create` | Whether to create resources | `bool` | `true` | no |
| `kms_key_arn` | KMS key (alias, key ID, or ARN) for encryption at rest | `string` | `data.aws_kms_alias.main.arn` | no |
| `display_name` | Display name of the topic | `string` | `"Demo"` | no |
| `fifo_topic` | Whether to create a FIFO topic | `bool` | `false` | no |
| `content_based_deduplication` | Content-based deduplication (FIFO only) | `bool` | `false` | no |
| `fifo_throughput_scope` | `Topic` or `MessageGroup` (FIFO only) | `string` | `"MessageGroup"` | no |
| `archive_policy` | Message archive policy JSON (FIFO only) | `string` | `jsonencode({ MessageRetentionPeriod = 30 })` | no |
| `signature_version` | `1` (SHA1) or `2` (SHA256) | `number` | `2` | no |
| `tracing_config` | `PassThrough` or `Active` | `string` | `"Active"` | no |
| `create_topic_policy` | Whether to create the topic access policy | `bool` | `true` | no |
| `access_policy` | List of access policy statements. Replaces the default policy(`templates/access-policy.tftpl`) entirely. `Resource` defaults to the topic ARN | `any` | See [Usage](#usage) | no |
| `delivery_policy` | Delivery policy object (or JSON string). Defaults to `templates/delivery-policy.tftpl`. Ignored for FIFO topics | `any` | See [Usage](#usage) | no |
| `data_protection_policy` | Data protection policy JSON (standard topics only) | `string` | `jsonencode({...})` | no |
| `subscriptions` | Map of subscriptions. The map key is a stable identifier | `map(object)` | See [Usage](#usage) | no |
| `application_feedback`<br/>`firehose_feedback`<br/>`http_feedback`<br/>`lambda_feedback`<br/>`sqs_feedback` | Delivery status logging roles and success sample rate(0 ~ 100) | `object` | `{ failure_role_arn = "...", success_role_arn = "...", success_sample_rate = 75 }` | no |
| `tags` | Additional tags | `map(string)` | `{ Team = "devops" }` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The ID of the SNS topic |
| `arn` | The ARN of the SNS topic |
| `name` | The name of the SNS topic |
| `owner` | The AWS Account ID of the SNS topic owner |
| `subscriptions` | Map of subscription keys to their ARNs |
| `topic_policy` | The access policy JSON attached to the SNS topic |

## Policy Templates

Default policies are rendered with `templatefile` from the templates under `templates/`.

| Template | Rendered by | Variables |
|----------|-------------|-----------|
| `templates/delivery-policy.tftpl` | `aws_sns_topic.this` `delivery_policy` (default, when `delivery_policy` is not set. Disabled for FIFO topics) | - |
| `templates/access-policy.tftpl` | `aws_sns_topic_policy.this` (default, when `access_policy` is not set) | `context.account_id`, topic ARN |

This module supports the AWS public partition (`aws`) only.

The default access policy allows the topic owner account(`AllowDefaultAccess`) and denies publishing over HTTP(`DenyInsecureTransport`).

## Migration from v1.0.x

> v1.1.0 includes breaking changes. Run `terraform plan` and review the changes before applying.

- AWS Provider `>= 6.0.0` is required.
- `subscriptions` is changed from `list` to `map(object)`. Move existing subscriptions to the new keys to avoid re-creation.

  ```
  terraform state mv 'module.demo.aws_sns_topic_subscription.this["0"]' 'module.demo.aws_sns_topic_subscription.this["apple_mail"]'
  ```
- `*_feedback` variables are changed from `map(string)` to `object`. Unknown keys are no longer allowed.
- The default access policy and the default delivery policy are applied to existing topics even if no variables are changed.
- The topic policy is always created by default (`create_topic_policy = true`). It is rendered from `access_policy`, or from `templates/access-policy.tftpl` when `access_policy` is not set.
- `delivery_policy` accepts an object (a JSON string is still accepted). When it is not set, `templates/delivery-policy.tftpl` is applied as the default delivery policy. The delivery policy is always disabled for FIFO topics.
- `policy` is replaced by `access_policy`, a list of policy statements. Each statement must have a unique `Sid`. `data.aws_iam_policy_document` is no longer used.
- The `arn` output now returns `null` when `create = false`.

## Appendix 

### Git Tagging

```
# tagging 
git tag v1.1.0 

# push to tag
git push origin v1.1.0            
```




