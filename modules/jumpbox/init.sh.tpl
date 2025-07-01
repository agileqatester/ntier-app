#!/bin/bash
dnf update -y
dnf install -y python3 pip ansible postgresql jq unzip curl

# Install kubectl
curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Create DB and schema
echo "Creating initial DB and schema..."
export PGPASSWORD=$(aws secretsmanager get-secret-value --secret-id ${rds_secret_arn} --query SecretString --output text | jq -r .password)
export PGUSER=$(aws secretsmanager get-secret-value --secret-id ${rds_secret_arn} --query SecretString --output text | jq -r .username)
psql -h ${rds_host} -U $PGUSER -c "CREATE DATABASE ${db_name};"
psql -h ${rds_host} -U $PGUSER -d ${db_name} -c "CREATE SCHEMA IF NOT EXISTS ${db_name};"
