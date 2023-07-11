# Infrastructure

## AWS Zones
Identify your zones here
**Primary Region**: us-east-2\
**Secondary Region**: us-west-1

## Servers and Clusters
- RDS Clusters (Multi AZ) in each region
- Elastic Kubernetes Service Cluster (2 nodes) per region
- 3 EC2 Virtual Machines per region
- 1 Application Load Balancer per region
- 2 S3 Buckets per region



### Table 1.1 Summary
| Asset                      | Purpose                                                                                   | Size        | Qty | DR                                                                            |
|----------------------------|-------------------------------------------------------------------------------------------|-------------|-----|-------------------------------------------------------------------------------|
| RDS Cluster                | AWS Managed Relational Database Service                                                   | db.t2.small | 2   | Deployed in multiple availability zones, and replicated to a secondary region |
| EKS Cluster                | Kubernetes service for deploying monitoring stack                                         | t3.medium   | 2   | Deployed in primary and secondary regions for DR                              |
| Application Load Balancer  | Load balancer pointing to ec2 servers                                                     |             | 2   | Deployed in primary and secondary regions for DR                              |
| EC2 Instances              | Virtual Machines hosting application                                                      | t2.micro    | 3   | 3 nodes deployed in each region                                               |
| Amazon Machine Image (AMI) | Base Image for creating ec2 instances hosting application                                 |             | 1   | 1 in each region                                                              |
| SSH Key Pair               | Securing access to ec2 instances                                                          |             | 1   | 1 in each region                                                              |
| Security Groups            | Security rules for either allowing or restricting traffic to different AWS resources      |             |     | Each rule is replicated across regions                                        |
| S3 Bucket                  | Storage for terraform state files and AMI                                                 |             | 2   | 2 in each region for DR                                                       |
| VPC                        | Virtual Private Network hosting all provisioned resources in a region                     |             | 1   | 1 in each region                                                              |
| Subnets                    | Partitions of the VPC with pre-defined IP address range available for resource allocation |             |     | Replicated in each region                                                     |
| Prometheus / Grafana       | Monitoring stack for real time insight to application health and performance              |             | 2   | Replicated in each region                                                     |
| IAM Roles                  | Sets of identities, permissions and policies managing access to all created resources     |             | 2   | Replicated in each region        

### Descriptions
More detailed descriptions of each asset identified above.
- **RDS Cluster:** Two instances nodes of RDS deployed into multiple availability zones in the primary("us-east-2a", "us-east-2b") and Disaster Recovery region("us-west-1b", "us-west-1c"). They are launched into private database subnets and their backup retention period is set to 5 days as specified in the requirements.
- **EKS Cluster:** Kubernetes cluster setup for deploying the application monitoring stack comprising Prometheus and Grafana, several IAM policies and a set of 2 worker nodes are configured as part of the cluster. This is setup in DR site as it is a critical component
- **VPC:** A Virtual Private Cloud which serves as a network container and boundary to all provisioned resources within a region. Private and Public Subnets are created with respective network configurations to either allow or restrict access from the internet or outside the VPC. A fixed amount of IP addresses are allocated within subnets as a CIDR block.
- **S3 Buckets:** Globally unique object storage provisioned mainly for storing remote terraform state. This is required in both primary and DR region.
- **AMI Images:** The AMI contains the application runtime and executable, this is similar concept to docker images. They are prepackaged and ready to start handling requests immediately, they save the time required for configuring each provisioned EC2 instance. It is copied over to the secondary region from the primary.
- **EC2:** Virtual Machines running actual application software, they are launched with a custom AMI and replicated to 3 nodes as per the requirements. The traffic is spread across all instances using the ALB. This is a critical business component hence it must be replicated on the DR site.
- **Security Groups:** Firewalls that help to inspect and filter traffic to prevent unauthorized resource access at the host, network, and application-level boundaries.
- **Keypairs:** SSH Key pairs needed for secure access to ec2 instances. This is a key security component and should be replicated as well.


## DR Plan
### Pre-Steps:
List steps you would perform to setup the infrastructure in the other region. It doesn't have to be super detailed, but high-level should suffice.

- Ensure the Infrastructure as Code (IaC) is up to date and in sync with infrastructure in the primary region.
- Ensure IaC (terraform files and modules) is safely stored in a repository outside of the primary and secondary regions.
- Create S3 bucket for Terraform state and AMI
- Copy over AMI 
- Using terraform, initialize a remote backend on DR region and deploy infrastructure resources.
- The above step builds and provisions all needed resources including VPC, Subnets, RDS Cluster, EC2 Instances, SSH keys, ALB, and EKS Cluster.
- Ensure RDS Cluster in DR site is properly setup as a read replica of the primary cluster.



## Steps:
You won't actually perform these steps, but write out what you would do to "fail-over" your application and database cluster to the other region. Think about all the pieces that were setup and how you would use those in the other region

- ### RDS Database Cluster FailOver:
  - Promote the RDS cluster in secondary region from Read Replica to Regional cluster (enabling both write and read traffic).
  - Manually point flask applications to the new reader and writer endpoints of the newly promoted cluster nodes.
  - Alternatively a generic CNAME DNS record could be configured to fail-over automatically using health checks

- ### Application FailOver:
  - Configure the DNS service in use(Amazon Route 53) to point to the load balancers in both the primary and secondary region
  - Health checks can be configured into Route 53, allowing an automatic fail-over to the DR load balancer when the primary goes offline
