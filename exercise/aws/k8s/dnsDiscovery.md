# Microservices: AWS: K8s
# DNS Discovery

### Objective



### Parts



# DNS Discovery

Let's add a test deployment to our newly created cluster to demonstrate that it can start pods and create other resources.  For this we will just use a nginx image:

~~~shell
kubectl create deployment nginx --image=nginx:1.17
~~~

You should be greeted with a message indicating what it has created the new deployment, "deployment.apps/nginx created".

Let's verify the status of the "nginx" deployment:

~~~shell
kubectl get deployments
~~~

After a short period of time sou should notice a "1/1" in the "Ready" column for the "nginx" deployment.  That deployment creates a kubernetes replicaset to manage pods.

Let's verify the status of the "deployment/nginx" "replicaset":

~~~shell
kubectl get replicasets
~~~

Let's also look at the status of the pods that where created by the "replicaset":

~~~shell
kubectl get pods
~~~

To demonstrate services discovery we need to create a kubernetes service to publish this service on a ClusterIP.  We can use the "kubectl expose" context to create this service exposing the "deployment/nginx":

~~~shell
kubectl expose deployment nginx --port=80
~~~

To demonstrate DNS discovery let's connect into a shell of a container running inside a pod on the Kubernetes cluster.  We will use an image that includes curl so we can connect to the website:

~~~shell
kubectl run --generator=run-pod/v1 curl-${LAB_NUMBER} --image=radial/busyboxplus:curl -i --tty --rm
~~~

Running the previous command will present you with a shell inside the kubernetes cluster.  From there lets demonstrate that by utilizing DNS we can find a service.  We will start with doing a lookup:

~~~shell
nslookup nginx.default.svc.cluster.local
~~~

In this case "nginx.default.svc.cluster.local" is the fqdn of the service that directs traffic to the backend nginx pods.  We see that inside the cluster pods can resolve the IP address by hostname.  Not only that but because the pod we are connected to exists in the same kubernetes namespaces ("default" namespace) as the nginx service we can just use the service name:

~~~shell
nslookup nginx
~~~

Let's also demonstrate we can connect to the "nginx" service:

~~~shell
curl http://nginx
~~~

When you are finished with the pod we have a shell running in, you can exit it by typing "exit" or "ctl-d".  That pod will cleanup after itself because we started it with the "--rm" option.

Let's now remove the "nginx" deployment.  Removing the "deployment" will also cascade down and remove the associated "replicasets" and "pods":

~~~shell
kubectl delete deployment nginx
~~~

In Kubernetes the service is loosely coupled to the deployment so we also should cleanup the service we created with the "kubectl expose" command earlier:
~~~bash
kubectl delete service nginx
~~~
