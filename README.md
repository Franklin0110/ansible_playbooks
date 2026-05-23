# ansible_playbooks
This is going to have all the ansible playbooks to practice. 
As requirements for the roles to work.

First we will need a Main machine or ansible machine which is going to run all the playbooks, I personally recommend using U.24.04 for this kind of project for all machines. 
Remember to install all ansible packages before moving to the next steps. 

The cluster is composed by the next. 
1. One Ansible Machine with ssh access to all other machines. 
2. Main machine which will do the creation of the cluster.
3. As many Kmasters as you wish.
4. As Many knodes as you wish.
NOTE: All of them need to be accesible through the ansible machine.

We have sucessfully until now.

From the Ansible machine you can copy this repository without problems, and then run the next. 

ansible-playbook ./playbooks/master_config.yaml

This will do all for you, as long as you configure 2 things correctly. 
1. The inventory of the Main Kmaster Machine.
2. Configure control_plane_endpoint: with the right IP. (We must automate this in the future in some way)


1. Created a Role that creates a Kubernetes cluster from scratch.
2. Created a Role that configures New kmasters and add thems into the created cluster (Configuration files might be needed for this one)
