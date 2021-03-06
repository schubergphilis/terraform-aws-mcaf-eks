variable "create_node_group" {
  type        = bool
  default     = true
  description = "Whether or not to create a node group"
}

variable "log_retention" {
  type        = number
  default     = 7
  description = "Retention of CloudWatch logs for the EKS cluster"
}

variable "instance_types" {
  type        = list(string)
  default     = null
  description = "List of EC2 instance types to use for the worker nodes"
}

variable "name" {
  type        = string
  description = "Name of the cluster"
}

variable "scaling_config" {
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }
  description = "The config that is used for the node group scaling"
}

variable "subnet_ids" {
  type        = list(string)
  default     = null
  description = "List of subnet IDs to deploy EKS in"
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the cluster"
}
