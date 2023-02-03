# Terraform-Azure-Project
Terraform scripts that provision Azure resources.
In this project there are scripts that do the following:

1. Deploy an Azure virtual machine within a virtual network and a subnet with a network interface and a network security group allowing inbound SSH & RDP requests (Script can be found in the Virtual-Machine folder).

2. Deploy a Kubernetes cluster with two nodes and enable role based access control. This is done a module that also creates the other resources associated with the kubernetes cluster. (Script can be found in the Virtual-Machine folder).

3. Deploy the 4 main types of Load Balancers in azure.
