# DevOps Bootcamp Final Project Documentation

Welcome to the documentation for the DevOps Bootcamp Final Project. This project demonstrates an automated infrastructure-as-code (IaC) setup using Terraform and Ansible.

<img width="1024" height="863" alt="image" src="https://github.com/user-attachments/assets/939994d0-3a99-41e6-805a-8a2c9a0a80e4" />


## 🔗 Project Links
* **Web Application:** [web.shamimazmii.com](http://web.shamimazmii.com)
* **Monitoring Dashboard (Grafana):** [monitoring.shamimazmii.com](https://monitoring.shamimazmii.com)

---

##  Setup Guide

### 1. Infrastructure Deployment (Terraform)
1. Initialize Terraform: `terraform init`
2. Preview changes: `terraform plan`
3. Deploy resources: `terraform apply -auto-approve`
4. Copy the Instance IDs from the outputs for the next steps.

### 2. Configuration Management (Ansible)
1. Log in to the Ansible Controller via SSM:
   `aws ssm start-session --target <ANSIBLE_INSTANCE_ID> (from your local wsl)`
2. Run the master playbook:
   `ansible-playbook site.yml`

### 3. Monitoring Setup
1. Use Cloudflare Tunnel to expose the Monitoring Server securely.
2. Access Grafana at your monitoring URL.
3. Import Dashboard ID `1860` to see Web Server metrics (CPU, RAM, Disk).
