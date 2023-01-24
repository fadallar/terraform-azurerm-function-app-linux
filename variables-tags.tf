variable "default_tags_enabled" {
  description = "Option to enable or disable default tags."
  type        = bool
  default     = true
}
variable "default_tags" {
  description = "Default Base tagging"
  type        = map(string)
  default     = {}
}

variable "extra_tags" {
  description = "Extra tags to add."
  type        = map(string)
  default     = {}
}