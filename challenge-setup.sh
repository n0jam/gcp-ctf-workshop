#!/bin/bash

# variables
read -p "Your GCP project ID: " PROJECT_ID
ZONE=europe-west1-b
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID | grep projectNumber | tr -d -c 0-9)

#  create directory for temporary files
mkdir temporary_files
#
# the compute engine for challenge 3 gets created in its own terraform run
# this is done to get an extra state file that we can leak on the storage bucket
# create it first so that we have the state file, and to give it some time to boot
# create ssh key for vulnerable compute VM
if [ ! -f temporary_files/leaked_ssh_key ]; then
ssh-keygen -t ed25519 -C "alice" -f temporary_files/leaked_ssh_key -N ''
fi

echo "##########################################################"
echo "> Beginning terraform setup for - challenge 3."
echo "##########################################################"
cd terraform_challenge3
terraform init -input=false
terraform plan -out tf.out -var project-id="$PROJECT_ID" -var project-number="$PROJECT_NUMBER" -input=false
terraform apply -input=false "tf.out"
cd ../

# set up resources with terraform
echo "##########################################################"
echo "> Beginning terraform setup for - challenges 1, 2, 4 and 5."
echo "##########################################################"

cd terraform
terraform init -input=false
terraform plan -out tf.out -var project-id="$PROJECT_ID" -var project-number="$PROJECT_NUMBER" -input=false
terraform apply -input=false "tf.out"
cd ../

echo "##########################################################"
echo "> Setup for challenge 1."
echo "##########################################################"

# create a service account key for the account we will leak in challenge 1
gcloud iam service-accounts keys create temporary_files/challenge1-creds.json --iam-account=gkeapp-file-uploader@$PROJECT_ID.iam.gserviceaccount.com

# set up connection to the gke cluster created in challenge 1
gcloud container clusters get-credentials gke-cluster-challenge-1 --zone $ZONE --project $PROJECT_ID

# create a kubernetes secret containing the service account key
kubectl create secret generic gkeapp-file-uploader-account --from-file=temporary_files/challenge1-creds.json
# leave a hint in form of a label which bucket this service account can access
kubectl label secret gkeapp-file-uploader-account "bucket=file-uploads-$PROJECT_ID"

# flag 1
kubectl create secret generic flag1 --type=string --from-literal=flag1="You found flag 1!"

# Configure cluster role bindings
kubectl apply -f manifests/roles.yaml 
kubectl apply -f manifests/bindings.yaml

echo "##########################################################"
echo "> Setup for challenge 2."
echo "##########################################################"


# flag 2
echo "You found flag 2!" > temporary_files/flag2.txt
gsutil cp temporary_files/flag2.txt gs://file-uploads-$PROJECT_ID

echo "##########################################################"
echo "> Setup for challenge 3."
echo "##########################################################"

# upload the state file to the storage bucket
gcloud storage cp gs://bsidesnyc2024terraform/terraform/challenge3/state/default.tfstate gs://file-uploads-$PROJECT_ID

COMPUTE_IP=$(gcloud compute instances describe  my-instance-challenge3 --project $PROJECT_ID | grep natIP | awk '{print $2}')
echo "You found flag 3!" > temporary_files/flag3.txt
scp -i temporary_files/leaked_ssh_key -o StrictHostKeyChecking=no temporary_files/flag3.txt alice@$COMPUTE_IP:/home/alice/

echo "##########################################################"
echo "> Setup for challenge 4."
echo "##########################################################"
#
# copy function invocation script on compute engine
scp -i temporary_files/leaked_ssh_key -o StrictHostKeyChecking=no ./invoke_monitoring_function.sh alice@$COMPUTE_IP:/tmp
# make the script executable and not writeable and owned by root
ssh -i temporary_files/leaked_ssh_key -o StrictHostKeyChecking=no alice@$COMPUTE_IP "sudo mv /tmp/invoke_monitoring_function.sh /usr/local/bin/; cd /home/alice && ln -s /usr/local/bin/invoke_monitoring_function.sh; sudo chmod 755 /usr/local/bin/invoke_monitoring_function.sh; sudo chown root:root /usr/local/bin/invoke_monitoring_function.sh"
# drop sudo privileges for alice
ssh -i temporary_files/leaked_ssh_key -o StrictHostKeyChecking=no alice@$COMPUTE_IP "sudo deluser alice google-sudoers"




echo "##########################################################"
echo "> Challenge setup complete!"
echo "##########################################################"
