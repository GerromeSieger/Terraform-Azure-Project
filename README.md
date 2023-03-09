# Terraform-Azure-Project
Terraform files that provision Azure resources.
In this project there are files that do the following:

1. Deploy an Azure virtual machine, a virtual network, a subnet, a network interface and a network security group allowing only inbound SSH traffic (Can be found in the Virtual-Machine folder)

2. Deploy a Kubernetes cluster with two nodes and enable role based access control. This is done a module that also creates the other resources associated with the kubernetes cluster (Can be found in the AKS folder)

3. Deploy an Azure Load Balancer, a virtual machine scale set, a backend pool of two vms from the sacle set, and health probes. (Can be found in the Load-Balancers/Azure-Load-Balancer folder)

4. Deploy an Azure Application gateway that serves as a load balancer for an app service with two web applications, a Web application firewall, a backend pool with the two web applications, a public ip address, and request routing rules (Can be found in the Load-Balancers/App-Gateway folder)

5. Deploy a Traffic Manager profile, two virtual machines in two different regions and resource groups with their respective virtual networks, subnets, network interfaces, two different dns zones and dns records and external endpoints (Can be found in the Load-Balancers/Traffic-Manager folder)

6. Deploy an Azure Frontdoor with frontend endpoints, backend pools, and routing rules. The backend pools consists of two web applications in two different regions. (Can be found in the Load-Balancers/FrontDoor folder)

7. Deploy a Postgres Database server within a virtual network and a subnet and with a virtual network rule, a redis cache and an azure key vault with access policies configured (Can be found in the Databases/Postgresql folder)

8. Deploy two CosmosDB accounts. The first one is of kind "MongoDB" and configures a mongo database and a mongo collection. The second one is an SQL database with a custom role definition and assignment and a configuration for a database and a container. (Can be found in the Databases/CosmosDB folder)

9. Configure IAM as code by creating two users in Azure Active directory and two groups and enabling dynamic membership to the two groups for the two users. Also creating a conditional access policy for one of the created users. (Can be found in the AzureAD folder)

10. Set us a virtual network peering that connects two virtual networks.


Terraform commands:

- terraform init

- terraform validate

- terraform plan -out=tfplan

- terraform apply "tfplan"
