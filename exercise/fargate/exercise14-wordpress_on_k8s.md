# Exercise 14: Wordpress on Kubernetes

In this exercise we will deploy a Wordpress instance on Kubernetes.  As we practice implementing everything as code we will use Kubernetes kustomize to deploy this wordpress with a single command to our existing Kubernetes cluster.  First lets switch to the source directory and look around a bit:
~~~bash
cd ~/microservices-bootcamp/exercise/fargate/source/14/wordpress/
~~~

As mentioned before will use kustomize to represent our group of Kubernetes resources with one command.  The main location that is defined is in the kustomization.yaml file.  Look through that file in addition to the additional mysql, wordpress and ingress yaml files.

When you are ready let's deploy this on the Kubernetes cluster running on your AWS Linux instance:
~~~bash
kubectl apply -k ./
~~~

As before we need the public IP to connect to:
~~~bash
echo $AWS_EIP
~~~

Now we should be able to connect to the wordpress instance at https://<AWS_EIP>/

You will need to accept the self-signed certificate to continue to the wordpress site.

When finished we can cleanup with one command also:
~~~bash
kubectl delete -k ./
~~~
