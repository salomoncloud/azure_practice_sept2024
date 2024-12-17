LEVEL 1 LAB NOTES AND STEPS ----


IDENTIFY ISSUE -
Go inspect boot diagnostics and serial console. You will find that the GRUB rescue mode is activated as the bootloader is lost and does not know where to point. (find better way to explain that)

Inspect Boot Diagnostics and Serial Console for errors. The system is currently in GRUB rescue mode, indicating that the bootloader cannot locate the operating system, likely due to a corrupted boot configuration

TROUBLESHOOT - 

Use the Azure CLI to add the VM repair extension and initiate the repair process.

az extension add -n vm-repair
az vm repair create -g rg-cgi-gto-cloud-lab02 -n  vmlab01
yes to public ip

Go get the ssh command from the connect menu for the rescue vm
open up local cli and paste that in
once inside;

lsblk – to identify the os disk
Could be worth mentioning the reason why you believe you know which is the correct disk (size, looking inside for files..)
mkdir /mnt/recovery
mount /dev/sdc1 /mnt/recovery
ls /mnt/recovery – Here we will be able to see that boot was spelled as bot, change it by running;
mv /mnt/recovery/bot /mnt/recovery/boot
verify the change; 
ls /mnt/recovery

REBUILDING OLD VM -
umount /mnt/recovery - to detach the mounted os disk
Back in the azure cli run; 
az vm repair restore -g rg-cgi-gto-cloud-lab02 -n vmlab01
Wait a bit, you’ll see that boot diagnostics and serial console are reporting that everything is fine, I still wont have access to log in but that should be okay.

CREATE BACK UP VAULT AND POLICY -
az backup vault create --location eastus2 --name salomonvault2 --resource-group rg-cgi-gto-cloud-lab02
create a json file named Policy_Salomon.json using vim
paste this in 

{
  "name": "Policy_Salomon",
  "properties": {
    "backupManagementType": "AzureIaasVM",
    "workloadType": "VM",
    "schedulePolicy": {
      "schedulePolicyType": "SimpleSchedulePolicy",
      "scheduleRunFrequency": "Daily",
      "scheduleRunTimes": [
        "2024-10-07T00:00:00Z"
      ],
      "timeZone": "UTC"
    },
    "retentionPolicy": {
      "retentionPolicyType": "LongTermRetentionPolicy",
      "dailySchedule": {
        "retentionTimes": [
          "2024-10-07T00:00:00Z"
        ],
        "retentionDuration": {
          "count": 30,
          "durationType": "Days"
        }
      }
    }
  }
}

than run this command

az backup policy create --backup-management-type AzureIaasVM --name Policy_Salomon --policy "$(cat Policy_Salomon.json)" --resource-group rg-cgi-gto-cloud-lab02 --vault-name salomonvault2 --workload-type VM

than enable

az backup protection enable-for-vm --policy-name Policy_Salomon --resource-group rg-cgi-gto-cloud-lab02 --vault-name salomonvault2 --vm vmlab01


PROVISIONING VM USING AZURE DEVOPS - 
To define the VM using Infrastructure as Code, use Terraform or ARM templates (I’ll use Terraform here). There will be the Terraform YAML configuration that Azure DevOps will execute to provision the VM.

Start by creating 2 folders in vscode; 1 called root that will have the yaml file, and another that will be called Terraform, holding the tf files.
Authenticate with az login in vscode cli.
Make sure you go to azure devops market place and install the terraform provider. 
Create a service connection for this azure devops project. 
Link VScode to the azure devops project using the commands below;
git remote add origin https://yourazureprojectlink
git push -u origin --all

1. Environment Setup:

The pipeline first checks out your code from the source repository (likely Git).
It then sets up the build environment using an Ubuntu virtual machine image.

2. Terraform Installation (Optional):

The pipeline attempts to install Terraform version 1.9.6.
It tries two methods:
Downloading the binary directly using wget (primary method).
Installing from HashiCorp's repository using curl and apt (fallback method).
This step is optional because you might already have Terraform installed on your CI/CD environment.

3. Terraform Initialization:

The pipeline navigates to your Terraform directory ($(Build.SourcesDirectory)/Terraform).
It then uses the Azure CLI task to run the terraform init command.
This command initializes Terraform and sets up the remote state backend using Azure Blob Storage with the configuration specified in -backend-config arguments.
Make sure these arguments match your actual configuration in Terraform files (storage account name, container name, resource group).

4. Terraform Plan:

The pipeline runs the terraform plan command twice:
Once for your main infrastructure defined in Terraform files.
Another time specifically for "Monitoring and Alerts" infrastructure (likely defined in separate Terraform files).
The -out flag specifies an output file named tfplan (or tfplan-monitoring) which contains the planned changes Terraform will make.
5. Terraform Apply with Approval (Optional):

The pipeline uses the Azure CLI task again to run terraform apply.
However, the -auto-approve flag is used, which would automatically apply the changes without prompting for confirmation.
Important: This is a dangerous option in production environments. It's recommended to remove -auto-approve and manually review the tfplan files before applying.

6. Publishing Artifacts (Optional):

The pipeline uses the PublishPipelineArtifact task to publish the generated tfplan files as artifacts.
These artifacts can be used for further analysis or manual approval before applying changes.

Overall, this YAML pipeline automates the process of setting up the environment, initializing Terraform, planning infrastructure changes, and potentially applying them (with caution). It relies on my Terraform files to define the actual infrastructure to provision.

TESTING VM AND ITS MONITORING - 

az vm user update --resource-group rg-cgi-gto-cloud-lab02 --name vmlab02 --username newuser --password 'NewPassword123!'

go to serial console and login

sudo apt-get install stress
stress --cpu 1 --timeout 600 &
