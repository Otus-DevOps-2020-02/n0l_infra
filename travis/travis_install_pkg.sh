#!/bin/bash

cd /tmp
curl -L -O https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_linux_amd64.zip
curl -L -O https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip
curl -L -O https://github.com/terraform-linters/tflint/releases/download/v0.13.4/tflint_linux_amd64.zip

ls -l
echo "install pkg"
sudo unzip -o -d /usr/local/bin/ "*.zip"
echo "remove zip"
rm *.zip
ls -l
echo "check pkg"

packer --version
terraform --version
tflint -v

pip install --user --upgrade pip
pip install --user ansible ansible-lint
cd ~
