**vpc setup using terraform over a linux ec2 instance**

STEP 1 INSTALL TERRAFORM ON THE INSTANCE

sudo yum install -y yum-utils

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

sudo yum -y install terraform

<img width="386" alt="image" src="https://github.com/aayushm96/devops_notes_vpc/assets/34830219/5f9dfff4-3266-4a8f-9189-e09f6eef6190">

STEP 2 SETUP A ROLE WITH FULL VPC ACCESS

setup role with full vpc access

<img width="593" alt="image" src="https://github.com/aayushm96/devops_notes_vpc/assets/34830219/1354ebab-c5ad-441b-a151-ab9f40624d4d">

STEP 3 INSTALL GIT AND CLONE THE REPO ON THE LINUX FOLDER
AND RUN TERRAFORM INIT AND TERRAFORM APPLY -AUTO-APPROVE

git clone <public_repo>

result

<img width="448" alt="image" src="https://github.com/aayushm96/devops_notes_vpc/assets/34830219/f98f3b23-d835-41c4-9f76-ab3e50b8dace">

