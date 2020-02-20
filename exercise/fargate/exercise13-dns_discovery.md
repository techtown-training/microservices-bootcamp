# Exercise 13: DNS Discovery

In this exercise we will be demonstrating DNS discovery to locate and connect to services in a cluster.  We will be utilizing Kubernetes in this lab.  We will be using a small simple distribution of Kubernetes known as microk8s.  Microk8s packages Kubernetes in a simple snap package and eliminates some of the complexities normally associated with installing Kubernetes.

So let's use "snap" to install Kubernetes with microk8s.
~~~bash
sudo snap install microk8s --classic
~~~

Let's check the status of microk8s and wait for it to be ready:
~~~bash
sudo microk8s.status --wait-ready
~~~

Microk8s bundles a number of optional Kubernetes additions.  Let's enable a few of them that we will be using in the labs:
~~~bash
sudo microk8s.enable dns storage ingress
~~~

It would be nice to be able to interact with microk8s without having to escalate privileges with sudo.  Fortunately there is a mechanism for that similar to how it is handled in Docker we can add our local user to the "microk8s" group:
~~~bash
sudo usermod -a -G microk8s $USER
~~~

If you remember from the installing Docker exercise, you will need to get your shell to read the new group to make it useful.  Go ahead and log out and log back in within a new shell.

Once you have restarted your shell.  Let's test it by displaying the "nodes" (hosts part of the kubernetes cluster) within this cluster without using sudo:
~~~bash
microk8s.kubectl get nodes
~~~

We also can look and see whet Kubernetes services are currently running within this cluster:
~~~bash
microk8s.kubectl get services
~~~

On last optional thing that we can do is add an alias for "kubectl" as that is the typical command that we normally would use to call the Kubernetes CLI:
~~~bash
alias kubectl='microk8s.kubectl'
~~~

Let's also make this alias permeant:
~~~bash
echo "alias kubectl='microk8s.kubectl'" >> ~/.bashrc
~~~

Let's add a test deployment to our newly created cluster to demonstrate that it can start pods and create other resources.  For this we will just use a nginx image:
~~~bash
kubectl create deployment nginx --image=nginx:1.17
~~~

You should be greeted with a message indicating what it has created the new deployment, "deployment.apps/nginx created".

Let's verify the status of the "nginx" deployment:
~~~bash
kubectl get deployments
~~~

After a short period of time sou should notice a "1/1" in the "Ready" column for the "nginx" deployment.  That deployment creates a kubernetes replicaset to manage pods.

Let's verify the status of the "deployment/nginx" "replicaset":
~~~bash
kubectl get replicasets
~~~

Let's also look at the status of the pods that where created by the "replicaset":
~~~bash
kubectl get pods
~~~

To demonstrate services discovery we need to create a kubernetes service to publish this service on a ClusterIP.  We can use the "kubectl expose" context to create this service exposing the "deployment/nginx":
~~~bash
kubectl expose deployment nginx --port=80
~~~

To demonstrate DNS discovery let's connect into a shell of a container running inside a pod on the Kubernetes cluster.  We will use an image that includes curl so we can connect to the website:
~~~bash
kubectl run --generator=run-pod/v1 curl-${LAB_NUMBER} --image=radial/busyboxplus:curl -i --tty --rm
~~~

Running the previous command will present you with a shell inside the kubernetes cluster.  From there lets demonstrate that by utilizing DNS we can find a service.  We will start with doing a lookup:
~~~bash
nslookup nginx.default.svc.cluster.local
~~~

In this case "nginx.default.svc.cluster.local" is the fqdn of the service that directs traffic to the backend nginx pods.  We see that inside the cluster pods can resolve the IP address by hostname.  Not only that but because the pod we are connected to exists in the same kubernetes namespaces ("default" namespace) as the nginx service we can just use the service name:
~~~bash
nslookup nginx
~~~

Let's also demonstrate we can connect to the "nginx" service:
~~~bash
curl http://nginx
~~~

When you are finished with the pod we have a shell running in, you can exit it by typing "exit" or "ctl-d".  That pod will cleanup after itself because we started it with the "--rm" option.

Let's now remove the "nginx" deployment.  Removing the "deployment" will also cascade down and remove the associated "replicasets" and "pods":
~~~bash
kubectl delete deployment nginx
~~~

In Kubernetes the service is loosely coupled to the deployment so we also should cleanup the service we created with the "kubectl expose" command earlier:
~~~bash
kubectl delete service nginx
~~~
