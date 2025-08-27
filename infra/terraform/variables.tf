variable "region" { default = "ap-south-1" }
variable "project" { default = "trend" }
variable "jenkins_instance_type" { default = "t3.medium" }
variable "key_name" { description = "EC2 keypair name" }
variable "allowed_cidr" { description = "Your IP/CIDR for Jenkins", default = "0.0.0.0/0" }
