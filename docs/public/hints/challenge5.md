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
