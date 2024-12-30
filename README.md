# AWS Event Management Application

 ![![image](https://github.com/user-attachments/assets/21a63c30-853c-4d46-b0f2-1eaa95f1ed8c)
](images/Screenshot 2024-12-31 025252.png)

## Project Overview

The AWS Event Management Application is a web-based platform for managing event registrations. The frontend is developed using HTML, CSS, and JavaScript, while the backend is powered by AWS Lambda functions triggered through AWS API Gateway. Event data is stored in Amazon DynamoDB, providing scalable and fast storage. The infrastructure is managed using Terraform, which allows for seamless deployment and teardown.

________________________________________
## Technology Stack
- **Frontend**: HTML, CSS, JavaScript
- **Backend**: AWS Lambda, AWS API Gateway
- **Database**: Amazon DynamoDB
- **Infrastructure as Code**: Terraform
- **Testing**: AWS IAM Simulation, AWS SAM Local for Lambda Testing
________________________________________
## Prerequisites
Before you begin, make sure you have the following:
-**AWS CLI** configured with the necessary permissions.
-**Terraform** installed to provision the infrastructure.
-**AWS Default VPC** (or modify the Terraform code to suit your VPC setup).
________________________________________
## Getting Started
### Clone the Repository
Clone the repository to your local machine:
```
Copy code
https://github.com/Featuremasters/Aws_Eventmanagement_app.git
cd AWS_EventManagement_app
```


### Initialize Terraform
To initialize Terraform and download the required providers, run:
```
Copy code
terraform init
```

### Run Terraform Plan
Before applying the changes, preview the resources that will be created or modified:
```
Copy code
terraform plan
```
This will show a detailed plan of the actions Terraform will take. Review the output to ensure everything looks correct before applying the changes.

### Provision AWS Resources
Once you've reviewed the plan, you can apply the configuration to provision the AWS resources (API Gateway, Lambda functions, DynamoDB table):
```
Copy code
terraform apply 
```
Terraform will ask for confirmation to proceed. Type yes to create the resources.

### Retrieve the API Gateway URL
After applying Terraform, you will receive an output with the API Gateway URL. Replace the placeholder <api-gateway-invoke-url> in your frontend JavaScript code with the actual API Gateway URL.
For example, update the following line in your JavaScript code:
```
Copy code
const apiEndpoint =`<api-gateway-invoke-url>/api/events`;

```

### Access the Application
Once the resources are deployed, open the provided URL in your browser to access the event registration form.
________________________________________

### Clean Up
To avoid incurring unnecessary costs, tear down the infrastructure after testing. Run the following command to remove the provisioned resources:
```
terraform destroy 
```

This will delete the API Gateway, Lambda functions, DynamoDB table, and other resources.
________________________________________

### Lambda Function Testing
During the development process:
1.	AWS IAM Simulation was used to simulate permissions and test Lambda function execution. This ensured the correct permissions were applied before deployment.
2.	AWS SAM Local was used to invoke the Lambda function locally to verify its functionality before deployment.

