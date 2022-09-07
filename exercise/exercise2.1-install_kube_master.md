## Verify and Install necessary components for Kubernetes Master

### Login to the machine

For Unix/Mac user

```
ssh -i Default.pem ubuntu@IP
```

For Windows user, <br>
Use putty and the ppk file to login. The username is `ubuntu`


### Package installation
```bash
sudo apt-get -y update
sudo apt-get -y install default-jdk git maven redis-tools
```

### Verify Docker

```
docker version
```

### Install Kubernetes tools

Add the package keys

```bash
curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg --output - | sudo apt-key add -
```

Add the Kubernetes package repository

```bash
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
```

Install Kubernetes tools

```bash
sudo apt install -y kubelet=1.19.2-00 kubeadm=1.19.2-00 kubectl=1.19.2-00 kubernetes-cni=0.8.7-00
```

Disable swap

```bash
sudo swapoff -a
```

### Verify kubectl installation

```bash
kubectl --help
```

initialize the kubernetes cluster with kubeadm (done only for master)

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=1.19.2
```

# create kubeconfig so the user can run kubectl commands
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

# Install flannel networking
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

Step 6 # Only when you want to use master node to host pods (since we have 1 node cluster)
```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### Test

```bash
kubectl get pods -o wide --all-namespaces
```

Now, you have one node cluster setup, up and running.


### Multi-node (Note that - we are not doing this as exercise !!)

In case you want to setup multi-node K8s cluster, <br>
*** Do not run `kubeadm init` command in the worker node. Instead run `kubeadm  token create --print-join-command` in the master node. This command will output a token, Copy and run the output of this command in the worker node. Repeat the same process for the number of worker nodes you want to join to the cluster.
