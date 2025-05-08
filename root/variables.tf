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
variable "prometheus_instance_name" {
  type = string
}
variable "prometheus_instance_type" {
  type = string
}
variable "prometheus_eip_domain" {
   type = string
}
variable "prometheus_key_pair" {
  type = string
}
variable "prometheus_ebs_volume_size" {
  type = number
}
variable "prometheus_ebs_volume_type" {
  type = string
}
variable "prometheus_vpc_name" {
  type = string
}
variable "prometheus_public_subnet_name" {
  type = string
}
variable "prometheus_sg_name" {
  type = string
}
variable "prometheus_ig_name" {
  type = string
}
variable "prometheus_route_table_name" {
  type = string
}