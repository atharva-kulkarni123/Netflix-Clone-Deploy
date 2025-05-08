module "jenkins-setup" {
    source = "../modules_jenkins_setup"
    providers = {
      aws = aws
    }
    key_pair = var.key_pair
    pem_file_name = var.pem_file_name
    instance_type = var.instance_type
    eip_domain = var.eip_domain
    instance_name = var.instance_name
    ebs_volume_size = var.ebs_volume_size
    ebs_volume_type = var.ebs_volume_type
    vpc_name = var.vpc_name
    public_subnet_name = var.public_subnet_name
    sg_name = var.sg_name
    ig_name = var.ig_name 
    route_table_name = var.route_table_name
}

module "monitoring-setup" {
    depends_on = [module.jenkins-setup]
    providers = {
      aws = aws
    }
    source = "../modules_monitoring_setup"
    prometheus_key_pair = var.prometheus_key_pair
    pem_file_name = var.pem_file_name
    prometheus_instance_type = var.prometheus_instance_type
    prometheus_eip_domain = var.prometheus_eip_domain
    prometheus_instance_name = var.prometheus_instance_name
    prometheus_ebs_volume_size = var.prometheus_ebs_volume_size
    prometheus_ebs_volume_type = var.prometheus_ebs_volume_type
    prometheus_vpc_name = var.prometheus_vpc_name
    prometheus_public_subnet_name = var.prometheus_public_subnet_name
    prometheus_sg_name = var.prometheus_sg_name
    prometheus_ig_name = var.prometheus_ig_name 
    prometheus_route_table_name = var.prometheus_route_table_name
}