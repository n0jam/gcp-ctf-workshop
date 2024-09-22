#!/bin/bash

# variables
read -p "Your GCP project ID: " PROJECT_ID
ZONE=europe-west1-b

# set up resources with terraform

cd terraform
terraform init -input=false
terraform plan -out tf.out -var-file=../ctf.tfvars -input=false
terraform apply -input=false "tf.out"
cd ../

# setup for challenge 1

# create a service account key for the account we will leak in challenge 1
gcloud iam service-accounts keys create challenge1-creds.json --iam-account=gkeapp-file-uploader@$PROJECT_ID.iam.gserviceaccount.com

# set up connection to the gke cluster created in challenge 1
gcloud container clusters get-credentials gke-cluster-challenge-1 --zone $ZONE --project $PROJECT_ID

# create a kubernetes secret containing the service account key
kubectl create secret generic gkeapp-file-uploader-account --from-file=./challenge1-creds.json

#ToDo:
# create misconfigured role binding to system-authenticated -> this opens up the challenge and makes the project vulnerable from outside attacks.
#

# setup for challenge 2

# create ssh key for vulnerable compute VM
if [ ! -f ./leaked_ssh_key ]; then
ssh-keygen -t ed25519 -C "alice" -f ./leaked_ssh_key -N ''
fi

# the compute engine for challenge 3 gets created in its own terraform run
# this is done to get an extra state file that we can leak on the storage bucket
cd terraform_challenge3
terraform init -input=false
terraform plan -out tf.out -var-file=../ctf.tfvars -input=false
terraform apply -input=false "tf.out"
cd ../

# upload the state file to the storage bucket
pwd
gcloud storage cp ./terraform_challenge3/terraform.tfstate gs://file-uploads-$PROJECT_ID

