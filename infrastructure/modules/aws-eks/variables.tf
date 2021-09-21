variable "environment" {
    type = string
}

variable "cluster_version" {
    type = number
    default = 1.21
}

variable "cluster_name" {
    type = string
}

variable "instance_type" {
    type = string
    default = "t3.medium"
}

variable "asg_max_size" {
    type = number
    default = 3
}