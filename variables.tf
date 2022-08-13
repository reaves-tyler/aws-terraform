variable "region" {
  default = "us-east-1"
  type    = string
}

variable "access_key" {
  sensitive = true
  default   = ""
  type      = string
}

variable "secret_key" {
  sensitive = true
  default   = ""
  type      = string
}
