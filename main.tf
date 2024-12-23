resource "aws_instance" "instances" {
  ami = data.aws_ami.ami.id
  vpc_security_group_ids = var.security_group
  instance_type = var.instance_type
  tags = {
    Name = var.name
  }
}

resource "aws_route53_record" "record" {
  name    = "${var.name}-dev.kroboshop.online"
  type    = "A"
  zone_id = var.zone_id
  ttl = 30
  records = [aws_instance.instances.private_ip]
}

resource "null_resource" "ansible" {
  depends_on = [
    aws_route53_record.record
  ]
  provisioner "local-exec" {
    command = <<EOF
cd /home/centos/roboshop-ansible
git pull
sleep 30
ansible-playbook -i ${var.name}-dev.kroboshop.online, main.yml -e ansible_user=centos -e ansible_password=DevOps321 -e component=${var.name}
EOF
  }
}