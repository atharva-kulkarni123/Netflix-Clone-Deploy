data "aws_ami" "ubuntu" {
  most_recent = true   # Ensures you get the latest AMI.
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
  domain     = var.eip_domain
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.netflix-instance.id
  allocation_id = aws_eip.instance_ip.id
}
resource "aws_instance" "netflix-instance" {
  vpc_security_group_ids = [aws_security_group.netflix-sg.id]  
  subnet_id              = aws_subnet.public.id
  ami           = data.aws_ami.ubuntu.id
  key_name      = var.key_pair
  instance_type = var.instance_type
  associate_public_ip_address = false
  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = var.ebs_volume_size
    volume_type           = var.ebs_volume_type
    delete_on_termination = true
  }
  tags = {
    Name = var.instance_name
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
      "sudo apt-get install -y docker.io",
      "sudo apt-get install -y git",
      "git clone https://github.com/N4si/DevSecOps-Project.git",
      "cd DevSecOps-Project && sudo docker build --build-arg TMDB_V3_API_KEY=<YOUR_TMDB_API_KEY> -t netflix .",
      "sudo docker run -d -p 80:80 netflix",
      "sudo docker pull sonarqube:lts-community",
      "sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community",
      "sudo apt-get install -y openjdk-17-jdk",
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo 'deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list",
      "sudo apt-get update -y",
      "sudo apt-get install jenkins -y ",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",
      "sudo usermod -aG docker jenkins",
      "sudo systemctl restart jenkins",
      "wget http://${aws_eip.instance_ip.public_ip}:8080/jnlpJars/jenkins-cli.jar -O jenkins-cli.jar",  
      "JENKINS_PASS=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)",
      "sudo java -jar jenkins-cli.jar -s http://${aws_eip.instance_ip.public_ip}:8080/ -auth admin:$JENKINS_PASS install-plugin blueocean"
    ]
  }
}
