variable "instance_name" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "eip_domain" {
   type = string
}
variable "key_pair" {
  type = string
}
variable "pem_file_name" {
  type = string
}
variable "ebs_volume_size" {
  type = number
}
variable "ebs_volume_type" {
  type = string
}
variable "vpc_name" {
  type = string
}
variable "public_subnet_name" {
  type = string
}
variable "sg_name" {
  type = string
}
variable "ig_name" {
  type = string
}
variable "route_table_name" {
  type = string
}