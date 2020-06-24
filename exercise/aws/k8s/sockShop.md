# Microservices: AWS: K8s
# Sock Shop

### Objective

Deploy Sock Shop Microservices Application on Kubernetes.

### Parts

### Warning

_This lab currently takes to many resources on a single node K8s cluster, do not apply it if you have less then 4GB of memory on a single node K8s cluster_

## Install Sock-Shop Application

### Download the sources

Start in the users home directory:

~~~shell
cd ~/
~~~

Clone the Sock Shop Microservices demo repository:

~~~shell
git clone https://github.com/microservices-demo/microservices-demo.git
~~~

Change to the Kubernetes deployment directory:

~~~shell
cd microservices-demo/deploy/kubernetes/
~~~

The `complete-demo.yaml` file currently included does not support the current versions of K8s.  We will replace it with a provided version.

Let's preserve the origional version so can compare the changes:

~~~shell
mv complete-demo.yaml complete-demo-orig.yaml
~~~

Now we can copy the new version of the `complet-demo.yaml` into place:

~~~shell
cp ~/microservices-bootcamp/exercises/aws/source/k8s/sockShop/complet-demo.yaml complet-demo.yaml
~~~

We can compare the canges that where made.  We can use the 'diff' tool to show the differences between the two files.  Look at the output to see what has changed.  Notices the "APIVersion" has been changed on the "Deployment" resources and a "selector" has been added for each.  At the end we also added a k8s ingress resource to provide an application layer proxy from TCP port 80 and 443:

~~~shell
diff complete-demo.yaml complete-demo-orig.yaml
~~~

## Just in case

Before we apply this application to our existing Kubernetes cluster let's put a safety net in place just in case we run out of memory on the Linux host and the 'oom killer' strikes.  These services take over 2GB of memory to run and most cloud systems including the standard AWS instances we generally us in the labs do not have swap enabled.

We can prevent k8s work from starting on the node after a reboot for now by disabling the k8s kubelet and kube-proxy:

~~~shell
sudo systemctl disable snap.microk8s.daemon-kubelet.service
sudo systemctl disable snap.microk8s.daemon-proxy.service
~~~

## Start the application

We need a k8s namespace called `sock-shop` to deploy the application into:

~~~shell
microk8s.kubectl create namespace sock-shop
~~~

Now we can "apply" the Sock Shop yaml file to the k8s cluster:

~~~shell
microk8s.kubectl apply -f complete-demo.yaml
~~~

Notice all the different k8s resources that where created?

Connecting to the Elastic IP of your AWS host should not present you with the Sock Shop frontend

___

### Let the Instructor know

Share a screenshot of the Sock Shop application with the instructor.

___

## Learn more.

The Sock Shop application is a complete demo application deployed as Microservices.  More info can be found upstream at the [Sock Shop Github page](https://microservices-demo.github.io/).  Look around not only at the application but also at the pods and services that make up the application.


Deployments:

~~~shell
microk8s.kubectl get deployments -n sock-shop
~~~

Deployments:

~~~shell
microk8s.kubectl get deployments -n sock-shop
~~~

Pods:

~~~shell
microk8s.kubectl get pods -n sock-shop
~~~

Services:

~~~shell
microk8s.kubectl get services -n sock-shop
~~~

Ingress:

~~~shell
microk8s.kubectl get ingress -n sock-shop
~~~

## Clean up

When we are finished we can delete Sock Shop application from the k8s cluster:

~~~shell
microk8s.kubectl delete -f complete-demo.yaml
~~~

Finally we also can remove the `sock-shop` namespace:

~~~shell
microk8s.kubectl delete namespace sock-shop
~~~

___
