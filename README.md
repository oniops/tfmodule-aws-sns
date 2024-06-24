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
  source  = "git::https://code.bespinglobal.com/scm/op/tfmodule-context.git"
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

module "demo" {
  source      = "git::https://code.bespinglobal.com/scm/op/tfmodule-aws-sns.git"
  context     = module.ctx.context
  name        = "demo"
  kms_key_arn = data.aws_kms_alias.main.arn
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "sqs.amazonaws.com"
        }
        Action    = "SNS:Publish"
        Resource  = module.demo.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = data.aws_sqs_queue.event.arn
          }
        }
      }
    ]
  })

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

  subscriptions = [
    {
      protocol = "email"
      endpoint = "apple@company.com"
    },
    {
      protocol = "email"
      endpoint = "banana@company.com"
    },
    {
      protocol = "sqs"
      endpoint = data.aws_sqs_queue.event.arn
    },
  ]
}


```

## Input Variables

| Name | Description | Type | Example | Required |
|------|-------------|------|---------|:--------:|
| -    | -           | -    | -       |    -     |

## Outputs

| Name | Description |
|------|-------------|
| -    | -           |



## Reference




