# ansible_playbooks
This is going to have all the ansible playbooks to practice. 
As requirements for the roles to work.

First we will need a Main machine or ansible machine which is going to run all the playbooks, I personally recommend using U.24.04 for this kind of project for all machines. 
Remember to install all ansible packages before moving to the next steps. 

The cluster is composed by the next. 
1. One Ansible Machine with ssh access to all other machines. 
2. Main kmaster machine which will do the creation of the cluster.
3. As many Kmasters as you wish.
4. As Many knodes as you wish.
NOTE: All of them need to be accesible through the ansible machine.


From the Ansible machine you can copy this repository without problems, and then run the next. 

ansible-playbook ./playbooks/master_config.yaml

This will do all for you, as long as you configure 2 things correctly. 
1. The inventory with the right IPs
2. In the KVM where you are going to create the machines, you must have the repository copied at ~/, and with write access to the repository. (Can be an ssh key if needed)
3. 
We have sucessfully until now.
1. Created a Role that creates a Kubernetes cluster from scratch.
2. Created a Role that configures New kmasters and add thems into the created cluster (Configuration files might be needed for this one)
3. We have created a script to create a machine with all the required information just by running the script with the hostname that you want, for example. 

bash root@kvm01:~/ansible_playbooks/scripts# bash generate_seed.sh kmaster02
NOTE: Everytime you create a machine, the KVM will write it into the [Stagging] part in the inventory file, you must move it as you wish. 

This will create the machine with all the required stuff fors us to run the playbooks, we just need to put the IPs in the right zone in the inventory files. 

We have 3 Different playbooks. 
1. For create the cluster.
2. To add new kmasters
3. (SOON) To add new workers

Everything is configured for you just run ansible_playbook <the playbook>
