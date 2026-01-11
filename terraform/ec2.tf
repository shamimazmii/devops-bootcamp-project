#Web Server
resource "aws_instance" "web" {
  ami                         = "ami-00d8fc944fb171e29"
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true
  private_ip                  = "10.0.0.5"
  key_name                    = "my-key"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "web-server"
  }
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
}

#Ansible
resource "aws_instance" "ansible" {
  ami                         = "ami-00d8fc944fb171e29"
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.private.id]
  associate_public_ip_address = false
  private_ip                  = "10.0.0.135"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  user_data_replace_on_change = true
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    sudo snap install amazon-ssm-agent --classic
    sudo apt install software-properties-common -y
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible -y
    sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
	  sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
    ansible-galaxy install geerlingguy.docker
    ansible-galaxy collection install community.docker
  EOF

  tags = {
    Name = "ansible-controller"
  }
}

#Monitoring
resource "aws_instance" "monitoring" {
  ami                         = "ami-00d8fc944fb171e29"
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.private.id]
  associate_public_ip_address = false
  private_ip                  = "10.0.0.136"
  key_name                    = "my-key"
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  
  user_data_replace_on_change = true
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    sudo snap install amazon-ssm-agent --classic
    sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
	  sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
  EOF

  tags = {
    Name = "monitoring-server"
  }
}

#SSM Role
resource "aws_iam_role" "ssm_role" {
  name = "EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "EC2-SSM-Profile"
  role = aws_iam_role.ssm_role.name
}


#Outputs
output "ansible_controller_instance_id" {
  description = "The Instance ID of the Ansible Controller EC2 instance."
  value       = aws_instance.ansible.id
}

output "monitoring_server_instance_id" {
  description = "The Instance ID of the Monitoring Server EC2 instance."
  value       = aws_instance.monitoring.id
}

output "web_server_instance_id" {
  description = "The Instance ID of the Web Server EC2 instance."
  value       = aws_instance.web.id
}

output "web_server_private_ip" {
  description = "The private IP of the Web Server EC2 instance."
  value       = aws_instance.web.private_ip
}