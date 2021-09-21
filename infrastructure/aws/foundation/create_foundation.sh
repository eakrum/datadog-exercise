#!/usr/bin/env bash

set -e

terraform init

terraform plan \
   -var-file="./terraform.tfvars" \
   -out="./terraform.tfplan" \
   -input=false 

echo "Please review the plan and type 'yes' to continue:"
read -r inputvar
if [[ $inputvar == "yes" ]]; then
   echo "applying"
   terraform apply \
         -input=false \
         "./terraform.tfplan"
fi