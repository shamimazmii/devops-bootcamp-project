variable "instance_type" {
  default = "t3.micro"
}

variable "private_key_path" {
  description = "Path to the private key file on local machine"
  type        = string
  default     = "~/.ssh/my-key.pem"
}