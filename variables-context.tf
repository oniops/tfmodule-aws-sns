variable "context" {
  description = "Provides standardized naming policy and attribute information for data source reference to define cloud resources for a Project."
  type        = object({
    account_id  = string
    region      = string
    project     = string
    name_prefix = string
    domain      = string
    pri_domain  = string
    tags        = map(string)
  })
}
