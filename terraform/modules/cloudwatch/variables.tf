variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "instance_ids" {
  description = "EC2 instance IDs to monitor"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
}
