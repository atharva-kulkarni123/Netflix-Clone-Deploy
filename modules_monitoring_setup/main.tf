data "aws_ami" "ubuntu" {
  most_recent = true # Ensures you get the latest AMI.
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical's official AWS account ID
}
resource "aws_eip" "instance_ip" {
  domain     = var.prometheus_eip_domain
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.prometheus-instance.id
  allocation_id = aws_eip.instance_ip.id
}
resource "aws_instance" "prometheus-instance" {
  vpc_security_group_ids      = [aws_security_group.monitoring-sg.id]
  subnet_id                   = aws_subnet.public.id
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = var.prometheus_key_pair
  instance_type               = var.prometheus_instance_type
  associate_public_ip_address = false
  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = var.prometheus_ebs_volume_size
    volume_type           = var.prometheus_ebs_volume_type
    delete_on_termination = true
  }
  tags = {
    Name = var.prometheus_instance_name
  }
}
resource "null_resource" "provision_jenkins" {
  depends_on = [aws_eip_association.eip_assoc]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.root}/${var.pem_file_name}")
    host        = aws_eip.instance_ip.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo useradd --system --no-create-home --shell /bin/false prometheus",
      "wget https://github.com/prometheus/prometheus/releases/download/v2.47.1/prometheus-2.47.1.linux-amd64.tar.gz",
      "tar -xvf prometheus-2.47.1.linux-amd64.tar.gz",
      "cd prometheus-2.47.1.linux-amd64 && sudo mkdir -p /data /etc/prometheus && sudo mv prometheus promtool /usr/local/bin/ && sudo mv consoles/ console_libraries/ /etc/prometheus/ && sudo mv prometheus.yml /etc/prometheus/prometheus.yml",
      "sudo chown -R prometheus:prometheus /etc/prometheus/ /data/",
      "sudo bash -c 'cat > /etc/systemd/system/prometheus.service <<EOF\n[Unit]\nDescription=Prometheus\nWants=network-online.target\nAfter=network-online.target\n\nStartLimitIntervalSec=500\nStartLimitBurst=5\n\n[Service]\nUser=prometheus\nGroup=prometheus\nType=simple\nRestart=on-failure\nRestartSec=5s\nExecStart=/usr/local/bin/prometheus \\\n  --config.file=/etc/prometheus/prometheus.yml \\\n  --storage.tsdb.path=/data \\\n  --web.console.templates=/etc/prometheus/consoles \\\n  --web.console.libraries=/etc/prometheus/console_libraries \\\n  --web.listen-address=0.0.0.0:9090 \\\n  --web.enable-lifecycle\n\n[Install]\nWantedBy=multi-user.target\nEOF'",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable prometheus",
      "sudo systemctl start prometheus",
      "sudo useradd --system --no-create-home --shell /bin/false node_exporter",
      "wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz",
      "tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz",
      "sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/",
      "rm -rf node_exporter*",
      "sudo bash -c 'cat > /etc/systemd/system/node_exporter.service <<EOF\n[Unit]\nDescription=Node Exporter\nWants=network-online.target\nAfter=network-online.target\n\nStartLimitIntervalSec=500\nStartLimitBurst=5\n\n[Service]\nUser=node_exporter\nGroup=node_exporter\nType=simple\nRestart=on-failure\nRestartSec=5s\nExecStart=/usr/local/bin/node_exporter --collector.logind\n\n[Install]\nWantedBy=multi-user.target\nEOF'",
      "sudo systemctl enable node_exporter",
      "sudo systemctl start node_exporter",
      "sudo apt-get install -y apt-transport-https software-properties-common",
      "wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -",
      "echo deb https://packages.grafana.com/oss/deb stable main | sudo tee -a /etc/apt/sources.list.d/grafana.list",
      "sudo apt-get update",
      "sudo apt-get -y install grafana",
      "sudo systemctl enable grafana-server",
      "sudo systemctl start grafana-server"
    ]
  }
}
