resource "aws_iam_role" "todo_role" {
  name               = "Jenkins-Terraform-SonarQube"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "todo_attachment" {
  role       = aws_iam_role.todo_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "todo_profile" {
  name = "Jenkins-Terraform-SonarQube"
  role = aws_iam_role.todo_role.name
}

resource "aws_instance" "web" {
  ami                    = "ami-03f4878755434977f" #change ami id for different region
  instance_type          = "t2.medium"
  key_name               = "jenkins" #change key name as per your setup
  vpc_security_group_ids = [aws_security_group.Jenkins-Terraform-SonarQube.id]
  user_data              = templatefile("./install.sh", {})
  iam_instance_profile   = aws_iam_instance_profile.todo_profile.name


  tags = {
    Name = "Jenkins-Terraform-SonarQube"
  }

  root_block_device {
    volume_size = 30
  }
}



resource "aws_security_group" "Jenkins-Terraform-SonarQube" {
  name        = "Jenkins-VM"
  description = "Allow TLS inbound traffic"

  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "inbound rules"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-Terraform-SonarQube"
  }
}
