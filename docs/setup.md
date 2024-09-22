# Setting up the challenge

The `challenge-setup.sh` script takes care of the setup.
It uses terraform to create the cloud resources.
It also sets up further configurations such as uploading files and configuring resources.
It generates some credential files used in the challenge such as ssh keys or service account keys. These files are added to the .gitignore file so that they don't get checked in.

To successfully run the script, you need the following prerequisites:
- a google cloud account, and the `Owner` role on a google cloud project, so you will have all permissions needed to create the challenge resources
- terraform
- gcloud and gsutil
- kubectl (can also be installed as a gcloud component with `gcloud components install kubectl`)

Steps to set up the challenge:
1. create a `ctf.tfvars` file in the root directory of this repository. It should have the following content:  
    ```
    project-id = <your gcp project id>
    project-number = <your gcp project number>
    ```
2. run the `./challenge-setup.sh` script.
   setting up the terraform resources, especially the GKE cluster, will take a few minutes
3. to make the cluster vulnerable from the internet, apply the two manifests in the `manifests` directory:  
   `kubectl apply -f manifests/clusterRole.yaml`
   `kubectl apply -f manifests/clusterRoleBinding.yaml`



# Cleaning up

To remove the resources created in your cloud project run the `challenge-destroy.sh` script.
It runs terraform destroy, and it cleans up the credential files we created. 
