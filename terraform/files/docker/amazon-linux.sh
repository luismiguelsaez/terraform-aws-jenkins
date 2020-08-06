#!/usr/bin/env bash

yum update -y
amazon-linux-extras install docker
systemctl enable docker
yum install -y amazon-ecr-credential-helper python3 python3-pip
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user

mkdir ~/.docker
cat << EOF > ~/.docker/config.json
{
	"credsStore": "ecr-login"
}
EOF