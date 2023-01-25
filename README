# eFuse work sample 

This repository contains version controlled files to launch basic nginx and whoami containers on Kubernetes, as well as IaC solution (Terraform) to deploy an S3 bucket in AWS.

### Prerequisits

In order to create the objects specified in requirements, we need

- Kubernetes cluster (in my case I used Kubeadm cluster in AWS cloud)
* Ingress controller installed on the cluster 
+ Terraform installed on your local or virtual machine
- AWS account with permissions to create resources in the AWS console, AWS CLI installed

<a id="customizing"></a>
## Step 1 :  Deploy a containerized application in Kubernetes

(nginx.yaml)(/nginx.yaml) contains a Kubernetes manifest, that launches the *nginx deployment* and *Cluster IP* service. We can create these resources using the following command: 
```
kubectl apply -f nginx.yaml
```
This will start the container and make it accessible on TCP port 80 on the cluster and it will also respond to both HEAD and GET request.

To make sure that the container responds to *Get* requests we can check the logs of container `kubectl logs deployment/nginx`, in the browser entering the IP address and port number of container, or using the `curl` command:

```
curl http://container-ip:container-port
```
*Head* requests:
```
curl -I http://container-ip:container-port
```

### Conclusion

Deployment, running nginx container, and nginx-service created. Container is exposed on port 80 and responds to both GET and HEAD requests.


<a id="customizing"></a>
## Step 2: Implement path-based routing for a Kubernetes ingress

Here I created a [whoami.yaml](/whoami.yaml) file to launch the containous/whoami container using Kubernetes and configure it to be exposed on TCP port 80 and respond to GET requests. To deploy a *whoami* deployment, service (Cluster IP) and ingress, run the following command:
```
kubectl apply -f whoami.yaml
```

`Ingress` exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.
In order for the Ingress resource to work, the cluster must have an ingress controller running. I used `ingress-nginx` downloaded from ingress-nginx [github repository](https://github.com/kubernetes/ingress-nginx):

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/baremetal/deploy.yaml
```
This will install all the necessary for ingress controller resources - pods, services, configmaps.

The ingress resource defines a rule that routes requests with a ` - path: /whoami` to the `whoami-service`, which is associated with the whoami container. All the other requests will go to `nginx_service`, created in previous step.

To verify that ingress is created and works, we can run
```
kubectl get ingress efuse-sample-ingress
```
```
kubectl describe ingress efuse-sample-ingress
```
If host is provided, we can check ingress using `curl`command: 
```
curl http://ingress-host
```

### Conclusion

Whoami deployment,whoami-service, `efuse-sample-ingress` ingress created. The `whoami` container is exposed on TCP port 80 and responds to GET requests. Ingress works as expected.


<a id="customizing"></a>
## Step 3: Implement an infrastructure-as-code solution to create an Amazon S3 bucket.

To implement the solution with required specifications, I used Terraform. [Terraform](/terraform/) folder contains modules, which create IAM user and S3 bucket.

Let's start with **IAM**. [Main.tf](terraform/modules/main.tf):
```
module "iam_user" {
    source = "./modules/IAM"
    user_name = "efuse"
    bucket_name = "efuse-bucket"
}
```
calls the module, located in *./modules/IAM* directory and passes in the variables, which we see inside the module. It will create an IAM user in the AWS account, along with access keys for that user:
```
resource "aws_iam_user" "efuse_user" {
  name = var.user_name
}
resource "aws_iam_access_key" "efuse_key" {
    user = aws_iam_user.efuse_user.name
}
```
You will also need to configure your AWS provider credentials in Terraform. This can be done using environment variables, a shared credentials file, or by including the credentials directly in your Terraform code.

It's important to note that you should store the AWS access key and secret key in a secure manner, such as in a secret manager. And also as a best practice it's recommended to use IAM roles instead of access keys whenever possible.

Next, we create a policy for `efuse` user, to grant permissions to access the S3 bucket, and attach the policy to IAM user: 
```
resource "aws_iam_policy" "efuse_policy" {
  name = "${var.user_name}-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}/*",
        "arn:aws:s3:::${var.bucket_name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "efuse" {
  user = aws_iam_user.efuse_user.name
  policy_arn = aws_iam_policy.efuse_policy.arn
}
```
This policy grants our `efuse` user permissions to: `s3:GetObject`, `s3:ListBucket`, `s3:PutObject`, `s3:PutObjectAcl`.

**S3**

The [main.tf](terraform/modules/main.tf)
```
module "s3" {
    source = "./modules/S3"
    bucket_name = "efuse-bucket"
    public_read_enabled = true
}
```
calls the module, which creates an S3 bucket with public read access. To change the puclic access to private, we simply define the variable `public_read_enabled` to *false* in [vars.tf](/terraform/modules/S3/vars.tf) file. This is a basic bucket, with minimal configuration. If needed we can provide additional properties, such as versioning, lifecycle.

The block 
```
resource "aws_s3_bucket_public_access_block" "efuse_block" {
  bucket = aws_s3_bucket.efuse_bucket.id
  block_public_acls = true
  ignore_public_acls = true
}
```
prevents public bucket object listing.

The last step is to upload files to the created S3 bucket using IAM user keys and AWS CLI.

In order to do that, we need to configure the IAM user credentials in `.aws/config` file in .aws/ directory, or pass them as environmental variables, and switch to `efuse_user`
```
export AWS_PROFILE=efuse_user
```
To upload files to S3 bucket, run the following command:
```
aws s3 cp name_of_the_file s3://efuse-bucket
```
To verify that file was uploaded run
```
aws s3 ls efuse-bucket
```


I pulled the access and secret keys for IAM user from the terraform state file, however it is not a best practice to keep them in the state file and push it into pulic repository. It would be better to create access keys manually and store them in password manager. Also, we could create an IAM role and attach it to the user for better security.

Modules make the code reusable for different environments, we just change values in terraform.auto.tfvars

