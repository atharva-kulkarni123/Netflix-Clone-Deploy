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
variable "pem_file_name" {
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