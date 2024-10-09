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
