# Kubernetes Cluster Automation with Ansible

This repository contains all the Ansible playbooks, roles, and scripts required to provision, configure, and manage a highly available Kubernetes cluster from scratch. 

## 🏗️ Architecture & Requirements

To successfully run this project, you will need the following infrastructure components. **Ubuntu 24.04** is highly recommended as the base operating system for all machines.

* **Ansible Control Node:** The main machine that will execute all playbooks. It must have the `ansible` package installed and require passwordless SSH access to all other nodes.
* **KVM Host:** The virtualization server where the cluster machines will be created. The repository must be cloned to `~/` on this host with write access (SSH keys recommended).
* **Primary Master Node (`kmaster01`):** The initial control plane node that bootstraps the cluster.
* **Secondary Master Nodes (`kmasters`):** Additional control plane nodes for High Availability (HA).
* **Worker Nodes (`knodes`):** The machines where your workloads and pods will run. 

> **Note:** All nodes must be reachable via SSH from the Ansible Control Node.

## ✨ Key Features & Capabilities

This repository automates the heavy lifting of Kubernetes administration and comes pre-configured with production-grade tooling:

* **Cluster Bootstrapping:** A complete role to initialize a Kubernetes cluster from scratch.
* **Highly Available Control Plane:** Architected to support an odd number of master nodes (e.g., 3 or 5) to maintain strict `etcd` quorum and prevent cluster state freezing during a node failure.
* **Automated Scaling:** Roles and playbooks to seamlessly configure and join new `kmasters` and `knodes` into the existing cluster.
* **VM Provisioning Script:** Easily spin up new KVM instances with a single command. 
* **Advanced OpenVPN Routing:** Includes a configured OpenVPN endpoint that automatically pushes routes for the Kubernetes Pod CIDR and Service CIDR, allowing connected clients to natively ping and resolve internal cluster IPs.
* **Internal DNS:** A fully configured internal DNS system for reliable local domain resolution across your cluster services.
* **GitOps Ready (ArgoCD):** Pre-configured with ArgoCD for continuous, automated deployment of your applications and manifests.
* **Full Observability:** Out-of-the-box deployment of Prometheus and Grafana to visualize cluster CPU/Memory usage, network traffic, and pod health.

## 🚀 Quick Start Guide

### 1. Provision a New Machine (Optional)
If you need to spin up a new node, use the included Bash script on your KVM host. For example, to create a new master node:

bash ~/ansible_playbooks/scripts/create_machine.sh kmaster02

Note: Every time you create a machine using this script, its IP/Hostname is automatically appended to the [staging] group in your Ansible inventory file. You must manually move it to the correct group (e.g., [kmasters] or [knodes]) before running the playbooks.

2. Configure Your Environment
Before running the playbooks, ensure you configure two crucial items:

Inventory File: Update inventory/hosts with the correct IP addresses for your masters and workers.

SSH Access: Ensure your Ansible machine can communicate with the newly provisioned IPs.

3. Run the Playbooks
We have modular playbooks depending on your goal. To execute the primary configuration, simply run:

```bash
ansible-playbook ./playbooks/master_config.yaml

Available Playbooks:

create_cluster.yaml: Bootstraps the initial Kubernetes Control Plane.

join_new_kmaster.yaml: Adds a new Control Plane node for HA.

join_new_knode.yaml: Adds a new Worker node to schedule workloads.

💡 Next-Level Recommendations for this Cluster
With HA, monitoring, and routing already implemented, here are the best practices to further harden and secure your cluster:

## 1. External Load Balancing (HAProxy)
Since you have HAProxy roles in your repository, ensure it is configured as an external load balancer sitting in front of your kmasters (targeting port 6443). All your worker nodes and external clients (including your Ansible automation) should communicate with the HAProxy virtual IP, rather than pointing to kmaster01. This guarantees true high availability if a master goes down.

2. Security & Secrets Management
Use Ansible Vault: Do not store sensitive data (like OpenVPN certificates, ArgoCD admin passwords, or Join Tokens) in plain text. Use ansible-vault to encrypt these variables in your repository.

Secure Ingress with Cert-Manager: You have cert-manager integrated. Ensure you configure ClusterIssuers (like Let's Encrypt or a local CA) to automatically provision TLS certificates for your public-facing ArgoCD dashboards and application ingresses.

3. GitOps Secrets Workflow
Separate Secrets from Git: ArgoCD syncs everything from Git, but you should never push Kubernetes Secret manifests to your repository. Implement a tool like External Secrets Operator or Sealed Secrets so ArgoCD can safely deploy encrypted secrets to your cluster.

4. Alerting & Backups
Configure Prometheus Alertmanager: You have the metrics visualized in Grafana. The next step is to configure Alertmanager to ping you (via Slack, Email, or Webhook) if a knode goes offline or if CPU usage spikes dangerously high.

Automate etcd Backups: Add a simple cronjob or an additional Ansible playbook that takes periodic snapshots of the etcd database and saves them to an external location (like an S3 bucket or external NAS). If your cluster suffers a catastrophic failure, this is the only way to restore it.
