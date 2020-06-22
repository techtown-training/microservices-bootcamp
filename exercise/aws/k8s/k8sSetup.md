# Microservices: AWS: K8s
# Kubernetes Setup

### Objective



### Parts




## Setup kubernetes

In this exercise we will be demonstrating DNS discovery to locate and connect to services in a cluster.  We will be utilizing Kubernetes in this lab.  We will be using a small simple distribution of Kubernetes known as microk8s.  Microk8s packages Kubernetes in a simple snap package and eliminates some of the complexities normally associated with installing Kubernetes.

So let's use "snap" to install Kubernetes with microk8s.

~~~shell
sudo snap install microk8s --classic
~~~

Let's check the status of microk8s and wait for it to be ready:

~~~shell
sudo microk8s.status --wait-ready
~~~

Microk8s bundles a number of optional Kubernetes additions.  Let's enable a few of them that we will be using in the labs:

~~~shell
sudo microk8s.enable dns storage ingress
~~~

It would be nice to be able to interact with microk8s without having to escalate privileges with sudo.  Fortunately there is a mechanism for that similar to how it is handled in Docker we can add our local user to the "microk8s" group:

~~~shell
sudo usermod -a -G microk8s $USER
~~~

If you remember from the installing Docker exercise, you will need to get your shell to read the new group to make it useful.  Go ahead and log out and log back in within a new shell.

Once you have restarted your shell.  Let's test it by displaying the "nodes" (hosts part of the kubernetes cluster) within this cluster without using sudo:

~~~shell
microk8s.kubectl get nodes
~~~

We also can look and see whet Kubernetes services are currently running within this cluster:

~~~shell
microk8s.kubectl get services
~~~

On last optional thing that we can do is add an alias for "kubectl" as that is the typical command that we normally would use to call the Kubernetes CLI:

~~~shell
alias kubectl='microk8s.kubectl'
~~~

Let's also make this alias permeant:

~~~shell
echo "alias kubectl='microk8s.kubectl'" >> ~/.bashrc
~~~