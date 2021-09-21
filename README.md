# DataDog Devops Exercise

### Opening Remarks
I've very much enjoyed working on this exercise and hope I can demonstrate my abilities as a DevOps Engineer for DataDog and the Demo Environment team. As discussed in the prompt, the assignment was to demonstrate DataDog's capabilities across a working application with the possibility of using different technologies throughout the frontend, backend, and any other parts of the stack. Although the prompt said we can use minikube or any other k8s-aaS platform I've decided to leverage my skillset as a DevOps engineer and demonstrate a relatively production ready solution with what was offered given the time constraint.

In this repository we have a fully automated and secure infrastructure written as code through terraform. The components of this cloud include a postgres RDS instance, VPC, EKS cluster, ECR Repos, and any other dependencies that may be a part of the solution such as DynamoDB tables, s3 buckets etc. What is excluded from this solution is full CI/CD given the time constraint as I wanted to focus on other parts to demonstrate.

In terms of the cloud this infrastructure is hosted on, I've tried to make the code as templated as possible to demonstrate the fact we can work out of multiple environments for this demo application. Furthermore I've also demonstrated common security practices such as leaving the database in a private subnet blocked from public internet as well as the EKS cluster while clients only interface load balancers. Although the EKS API is still open to public accessibility; given the fact incorporating a VPN solution would have cut into meaningful time for the rest of the exercise. 

Next piece of modern tech I've leveraged was docker and helm for our containers. I've also borrowed a baseline ToDO application from github authors and made several changes to them to adhere to DevOps best practices such as dockerizing the apps, creating env variables, and making them as production ready as possible. On top of this I also created a quick agent in python to repeatedly hit the API endpoints and generate synthetic data in the application while also having it under constant load. In order to make deployment of these applications as easy as possible I've created a helm chart for every single one which can be located in the `helm` directory. All of these apps run in the EKS cluster and I can give appropriate links where need be to interface them. 

Lastly to bring the whole piece of the puzzle together I incorporate the AWS integration from DataDog, APM monitoring on postgres and the API, and log collection across the entire cluster. 

## Getting Started

### Prerequisites
In order to run this project and follow the launching of this stack we will need to have the following tools installed on our machines. For reference I will also attach my version. 
1. Docker. Docker version 20.10.8, build 3967b7d
2. Terraform - 0.15.0
3. Python3 - 3.8.3 (local testing off apps only)
4. Node.JS - 14.13.1 (local testing of apps only)
5. AWS CLI - 2.2.3 

Furthermore you will need an AWS account to provision these resources with an appropriate `IAM profile` in your `~/.aws/credentials` file. I recommend attaching `AdministratorAccess` to this user only for the sake of testing this. Here is an example of my profile with the secrets redacted. 
```
[eakrum]
region = us-east-1
aws_access_key_id = xxxxxxxx
aws_secret_access_key = xxxxxxxxxx 
```

### Launching Infrastructure

NOTE: please export your AWS Profile so you are pushing to the appropriate cloud. 
for example: `export AWS_PROFILE=eakrum` and you can verify by running `aws s3 ls` to see if appropriate resources appear.

Now that we have our development environment ready we are now ready to launch infrastructure! Before we begin - let's walk through the code. We have 3 main folders here. 
- AWS
  - Holds foundational pieces for terraform i.e s3 state bucket creation and dynamo db table related code
  - Holds a subfolder called `us-east-` this is where all of our config files and directives lie for the `us-east-1` region.
- Modules
  - We can think of this folder as `classes`. Each module specifies how to launch a specific piece of infrastructure. 
- Scripts
  - Since we do not have a CI/CD solution I tried to automate as much as I could to make life a little easier through the use of some launch and destroy scripts.

Now that we have a basic gist of how the code is laid out - next is the basic order of operations we need to handle to get our terraform and resources up to spec.

#### Launching the foundation

As we know, with Terraform it needs an S3 bucket to manage state and a locking table to prevent teams from pushing the same changes simultaneously. To get these up and running I've provided a folder within `aws/us-east-1` called `foundation`. All of the specs can be found here and we can simply run `./create_foundation.sh` and follow the prompts to launch the baseline infra needed.

NOTE: S3 Buckets are global resources and I am still running my infrastructure for the team to test. Please reference `terraform.tfvars` to change the bucket name. 

#### Launching the AWS Environment

NOTE: adjust s3 bucket name in `us-east-1/environment/backend.tf` with value of your bucket.

Our AWS environment will consist of the basic barebones resources we need to launch the rest of our "metal". This is where we create our VPC, ACLs and SG's. To launch this simply run `./scripts/environment/launch-dev-env.sh` and follow the prompts.

#### Launching the RDS Instance

NOTE: adjust s3 bucket name in `us-east-1/environment/backend.tf` with value of your bucket.

Before we begin - we have a manual step here where we have to store our rds password in AWS parameter store [here](https://console.aws.amazon.com/systems-manager/parameters/?region=us-east-1&tab=Table) it is very important that we name the parameter `rds_password` exactly as is.

Our RDS instance will live in only private subnets be cut off by all traffic and only have accessibility from within the VPC.

Once this step is completed. Simply run `./scripts/rds/launch-dev-rds.sh` and follow the prompts.

#### Launching the EKS Cluster 

NOTE: adjust s3 bucket name in `us-east-1/environment/backend.tf` with value of your bucket.

Our EKS cluster will also have similar behavior to RDS with the exception of the K8s API being publicly accessible due to lack of VPN. The resources will still live in private subnets and the cluster is managed through AWS auth. To launch please execute `./scripts/dev/launch-dev-eks.sh` and follow the prompts.

We've now launched our infrastructure for the applicaton!

### Deploying the DataDog Agent onto the EKS Cluster and Enabling the DataDog AWS Integration

Since API requires APM and logs - we need to configure the agent onto our EKS cluster now. First we must update our kube config, I run this command to do so which leverages my AWS Profile. 
```
export AWS_PROFILE=<YOUR_PROFILE && aws eks update-kubeconfig --name development-eks-cluster --profile <YOUR_PROFILE>
```
Once this is completed cd into the `helm` directory of this repository. The run the following commands in this order.
1. `helm repo add datadog https://helm.datadoghq.com`
2. `helm repo update`
3. `helm install -f datadog-agent/datadog-values.yaml datadog --set datadog.apiKey=<YOUR_API_KEY> datadog/datadog` 

The datadog agent is now deployed onto the cluster!

Next we can enable the AWS integration through DataDog which launches a few cloudformation stacks as well so we can start monitoring our non EKS workloads and other metadata. The instructions for doing so can be found [here](https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation

### Dockerizing and Deploying API

NOTE: Please modify `helm/example-api/values.yaml` to account for your ECR repo! Follows this structure: `<YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/example-api`  

Because API is required for both of our other applications we are going to be dockerizing and deplpoying this first. From our infrastructure step we must grab our RDS endpoint which can be done from the RDS console, next we must also grab the RDS password which we specified in parameter store. After doing so, cd into `apps/example-api` and then run the following command: 
```
docker build -t <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/example-api:latest -f Dockerfile --build-arg DB_USERNAME=eakrum --build-arg DB_PASSWORD=<YOUR_PASSWORD> --build-arg DB_HOST=<YOUR_HOST> .
```
After the image has been built we must log into our ECR repository. I do this by running the following command:
```
aws ecr get-login-password --region us-east-1 --profile <YOUR_PROFILE> | docker login --username AWS --password-stdin <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

```

After logging into ECR, push up the newly created docker image: 

```
docker push <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/example-api:latest   
```

Lastly we can deploy the API using the helm chart! From the `helm` directory simply run 
```
helm install example-api example-api 
```

### Dockerizing and Deploying FrontEnd

NOTE: Please modify `helm/example-frontend/values.yaml` to account for your ECR repo! Follows this structure: `<YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/example-frontend`  

Because API is required for FrontEnd as an ENV var we must grab the respective endpoint that was created as part of the deployment. To do so, run 
```
kubectl get svc example-api
```
and copy the ELB associated with the service.

Next run: 
```
docker build -t <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/example-frontend:latest --build-arg TODO_API_URL=<YOUR_API_ENDPOINT>/api/ .
 .
```
After logging into ECR, push up the newly created docker image: 

```
docker push <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/example-frontend:latest   
```

Lastly we can deploy the Frontend using the helm chart! From the `helm` directory simply run 
```
helm install example-frontend example-frontend 
```
The frontend is now deployed!


### Dockerizing and Deploying Test Agent

NOTE: Please modify `helm/test-agent/values.yaml` to account for your ECR repo! Follows this structure: `<YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/example-frontend` 

Similarly for the FrontEnd - Test Agent also requires the API Endpoint as an `ENV VAR`. Because we don't have DNS we will have to grab the ELB name again.

Make sure you are still logged into ECR to push up images, if not log in again using previously defined command. Now let's build and push again!

From `apps/test-agent` run the following:

```
docker build -t <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/test-agent:latest --build-arg API_ENDPOINT=<YOUR_API_ENDPOINT> .
```
```
docker push <YOUR_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/test-agent:latest
```
Then from `helm` directory run:

```
helm install test-agent test-agent
```

Congratulations, the whole stack is now launched, provisioned via code, and monitored in DataDog!
