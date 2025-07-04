#!/bin/bash
set -e

# Variables passed from Terraform
AWS_REGION="${aws_region}"
CLUSTER_NAME="${cluster_name}"

dnf update -y
dnf install -y python3 pip ansible postgresql jq unzip curl 

# Install kubectl
#curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
#install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install AWS CLI v2 (Amazon Linux 2023 ships with minimal version)
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Install kubectl (for ARM64 — AL2023 on Graviton is aarch64)
ARCH=arm64
KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Create kubeconfig
aws eks update-kubeconfig \
  --region "$AWS_REGION" \
  --name "$CLUSTER_NAME"
  
# Create DB and schema
# echo "Creating initial DB and schema..."
# export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id ${rds_secret_arn} --query SecretString --output text | jq -r .password)
# export PGUSER=$(aws secretsmanager get-secret-value --secret-id ${rds_secret_arn} --query SecretString --output text | jq -r .username)
# psql -h ${rds_host} -U $PGUSER -c "CREATE DATABASE ${db_name};"
# psql -h ${rds_host} -U $PGUSER -d ${db_name} -c "CREATE SCHEMA IF NOT EXISTS ${db_name};"
