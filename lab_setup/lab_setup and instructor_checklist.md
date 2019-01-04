## Lab Setup for microservices-bootcamp course

### Create instances

- Select image `ami-09ae5ef93a75b002a` OR `microservices_kubernetes-bootcamp`
- Type of instance required `t2.medium`
- Enable `Auto-assign public IP`

```
*** Important
(in Step 3 - Configure Instance Details), click on Advanced Details and paste the below content in the User Data Field.

#!/bin/bash
sudo su - root
sudo sysctl net.bridge.bridge-nf-call-iptables=1
kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/master-
```
- 16G storage
- Select `all-in-all` security group


### Number of Instances required
1 per student


### Test connection and instance (for ASPE)
Login to one of the instances and run command `kubectl --help` to verify if Docker runs properly

### Test connection and instance (for clients)
Following needs to be sent to the client to test their connection

- IP address of one of the machines
- Default.pem/ppk files
- Word document with testing instruction
```
Test_Instance_and_Connection.docx
```

All required instruction for testing in mentioned in the word document.