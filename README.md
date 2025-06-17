# Node.js Application on AWS with Terraform, Docker, Jenkins CI/CD
Set up an automated, scalable, and secure infrastructure to deploy a containerized Node.js application. This includes CI/CD using Jenkins, infrastructure-as-code (IaC) using Terraform, secure deployment automation with Ansible and Shell scripts, and load-balanced high availability on AWS.

# Project Structure
    ├── terraform/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── backend.tf
    │   └── env/dev
    │           ├── main.tf
    │           ├── variables.tf
    │           ├── outputs.tf
    │           ├── dynamodb-backend.tf
    │   └── modules/
    │       ├── vpc/
    │           ├── main.tf
    │           ├── variables.tf
    │           ├── outputs.tf
    │       ├── ec2_asg/
    │       ├── alb/
    │       ├── rds/
    │       └── ecr/
    ├── Dockerfile
    ├── docker-compose.yml
    ├── .env
    ├── deployment.yml
    ├── docker.sh
    ├── Jenkinsfile
    ├── README.md

# Tech Stack
    Node.js – Application
    Docker – Containerization
    Docker Compose – orchestration
    Terraform – Infrastructure as Code on AWS
    Jenkins – CI/CD automation
    Ansible – EC2 deployment automation
    AWS Services – VPC, EC2, ASG, ALB, RDS, ECR, IAM, ACM, CloudWatch, SNS
    Monitoring – CloudWatch, Prometheus and Grafana
    Logging – CloudWatch Logs, ELK Stack

# 1. Application
    A basic Node.js application and postgresql version 13.
    Environment variables are managed via .env.

# 2. Docker & Docker Compose
    Used the node.js + alphine docker image
    Created the user in docker image and used that user to run the application
    Add the build/dist folder to docker image and create the image
    Exposed the port 3000
    Used the docker compose to create the containers in EC2 instances

# 3. Terraform Infrastructure
# Provisioned components:
    VPC with public/private subnets, NAT, IG, Route tables configuration
    EC2 Launch Template, Auto Scaling Group and SG's for EC2, ALB and RDS
    Application Load Balancer, Listener, Listener rule, TG and ACM
    RDS (PostgreSQL) in private subnet with multi-AZ 
    ECR for Docker image storage and IAM roles
    CloudWatch Logs & Alarms
    DynamoDB for Terraform state locking
State is stored in S3 and locked using DynamoDB.

# How to Deploy Infrastructure using Terraform
    a. Prerequisites
        AWS CLI configured (aws configure)
        Terraform installed
        AWS IAM user with necessary permissions

    b. Create the Terraform Backend (One-Time Step) using below commands
        cd terraform/env/dev
        terraform init
        terraform apply -target=aws_s3_bucket.tf_state -target=aws_dynamodb_table.tf_lock

    c. Deploy Environment
        cd terraform/env/dev
        terraform init 
        terraform plan   
        terraform apply 

# 4. CI/CD Pipeline Workflow (Jenkins) 
    Create Jenkins pipeline with multi-branch and integrate jenkins with GitHub, use secreates to store the GitHub credentials
    Trigger: Click on Build Now to run the pipeline (create multi-branch declerative pipeline and parameter to pass the application version and tag that version with docker image as a tag
    )
    Stages:
        Checkout: Clone the code to slave machine
        Test and build: Run tests and build the binaries
        Docker image creation: Build Docker image, tag it and push to ECR
        Deploy: Deploy the application to EC2 instances using ansible and docker-compose.
    Rollback: If health check fails post-deploy, auto-rollback using Ansible
    if we get the any error, we can check in the console output section

# 5. Security Best Practices
     Attached ACM with https listner
     Store the certificate to ACM
     Used the IAM roles
     Encrypted the EBS volume for RDS and EC2 
     Allowed only neccessory ports and IP's in SG

# 6. Monitoring & Alerting
# CloudWatch:
    Enable detailed monitoring on EC2, ALB, and RDS.
    Install and configure the CloudWatch Agent on EC2
    Create the SNS and configure the Email
    Create the Alert in cloudwatch dashboard in alert section, setup the alert, define the conditions and throushold, attach the SNS topic and then create the alert
    Also, for RDS dashboard only having the alerts section to create a alert for verious behaviors
    And also, under the cloudwatch logs group section, we can create alerts for metrics
    [CloudWatch → SNS Topic → Email]

# prometheus and Grafana:
    Install the prometheus and Grafana in linux servers
    Configure the prometheus with grafana in configuration file
    Install node_exporter on application server and configure with prometheus
    So node_exporter will send the metrics to prometheus
    And create the Dashboard in Grafana and we can see the server and application performance
    Configure the Alert also here

# 7. Logging and Debugging
# CloudWatch:
    Install the CloudWatch agent using the awslogs package in servers
    In /etc/awslogs/, update the configuration file with proper cloudwatch group name, log name, logs file and path and AWS region
    Once update all the configuration then restart the awslogs agent
    RDS default it will store the logs in cloudwatch, these logs are store in RDS also but 7 days is the retention period

# ELK: 
    Install and configure the elasticsearch and kibana
    Update the elasticsearch.yml file with grafana IP and port and grafana.yml files
    Restart the elasticsearch and kibana
    Install filebeat in application servers
    Update the filebeat.yml file with logs file and path, filters, elasticsearch and kibana IP and ports, index configuration
    Then Restart the filebeat so it will send the logs to elasticsearch and we can able to see logs in kibana after creating indexs in kibana dashboard


# Suggestions:
    1. Use the WAF to secure the application from attacks like SQL injection, cross-site scription, 2. DDOS attach, Rate limit, Request and responce body size
    3. Use API gateway to secure our application API's
    4. Use AWS Shield to prevent from DDOS attacks
    5. Enable AWS config and AWS Guard Duty
    6. Configure AWS cloudtrail to monitore the AWS account activities and setup a alerts when suspsuspicious activies happens
    7. Use Treand-Micro to monitore the EC2 instances like it will monitore the server setup and configuration
    8. Use Boundry service to login Ec2 and RDS 
    9. Instead of using EC2 to run docker applcation, we can go with ECS fargate or EKS, so these will support more futures and more flexible
    10. Instead of using ELK stack, we can go with Amazon OpenSearch also
    11. Run non-production env in spot instances for reducing the cost
    12. Create the RDS read replica, take every day backups
    13. Configure and schedule Patch manager to update the latest patchs to EC2 instances

