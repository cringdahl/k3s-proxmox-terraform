.PHONY: setup init plan apply deploy destroy clean state_check status ssh logs kubeconfig test outputs token ping info

# Default target
help:
	@echo "K3s on Proxmox - Available Commands:"
	@echo ""
	@echo "  make setup       - Run initial setup and check prerequisites"
	@echo "  make init        - Initialize Terraform"
	@echo "  make plan        - Show Terraform plan"
	@echo "  make apply       - Create VMs with Terraform"
	@echo "  make deploy      - Full deployment (Terraform + Ansible)"
	@echo "  make destroy     - Destroy all resources"
	@echo "  make clean       - Clean Terraform files"
	@echo ""
	@echo "  make status      - Show cluster status"
	@echo "  make ssh         - SSH to control plane"
	@echo "  make logs        - View K3s logs on control plane"
	@echo "  make kubeconfig  - Export kubeconfig"
	@echo "  make test        - Deploy test nginx application"
	@echo ""

setup:
	@echo "Running setup..."
	./setup.sh

init:
	@echo "Initializing Terraform..."
	terraform -chdir=terraform init

plan: init
	@echo "Planning deployment..."
	terraform -chdir=terraform plan

apply: init
	@echo "Applying Terraform configuration..."
	terraform -chdir=terraform apply
	@echo "Gathering SSH info from Terraform..."
	@terraform -chdir=terraform output -json cluster_info | jq -r '.control_plane.ips[0]' > control_plane_ip.tmp
	@terraform -chdir=terraform output -json cluster_info | jq -r '.workers.ips[]' > worker_node_ips.tmp
	@echo "Cluster IPs found and written to temp files"

deploy:
	@echo "Running full deployment..."
	./deploy.sh

destroy:
	@echo "Destroying infrastructure..."
	terraform -chdir=terraform destroy

clean:
	@echo "Cleaning Terraform files, but not destroying infrastructure..."
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* *.log *.tmp

state_check:
	@echo "Checking for Terraform output..."
	@terraform -chdir=terraform output -json cluster_info 2>/dev/null 1>/dev/null

status:
	@echo "Cluster Status:"
	@export KUBECONFIG=$(shell pwd)/kubeconfig && kubectl get nodes -o wide
	@echo ""
	@export KUBECONFIG=$(shell pwd)/kubeconfig && kubectl get pods -A

ssh: state_check
	@echo "Connecting to control plane..."
	@ssh ubuntu@$(shell cat control_plane_ip.tmp)

logs: state_check
	@echo "K3s logs from control plane:"
	@ssh ubuntu@$(shell cat control_plane_ip.tmp) "sudo journalctl -u k3s -n 50"

kubeconfig:
	@echo "Kubeconfig location: $(shell pwd)/kubeconfig"
	@echo ""
	@echo "Export with:"
	@echo "export KUBECONFIG=$(shell pwd)/kubeconfig"

test: state_check
	@echo "Deploying test nginx application..."
	@export KUBECONFIG=$(shell pwd)/kubeconfig && \
		kubectl create deployment nginx --image=nginx && \
		kubectl expose deployment nginx --port=80 --type=NodePort && \
		kubectl get svc nginx
	@echo ""
	@echo "Access nginx at: http://192.168.1.185:<NodePort>"

# Show Terraform outputs
outputs:
	@terraform -chdir=terraform output

# Get K3s token
token:
	@terraform -chdir=terraform output -raw k3s_token

# Ping all nodes
ping: state_check
	@echo "Pinging control plane..."
	@ping -c 3 $(shell cat control_plane_ip.tmp) > /dev/null && echo "✓ Control plane ($(shell cat control_plane_ip.tmp))" || echo "✗ Control plane unreachable"
	@echo "Pinging workers..."
	@WORKER_COUNT=0
	@for ip in $(shell cat worker_node_ips.tmp); do \
		WORKER_COUNT=$$((WORKER_COUNT+1)); \
		ping -c 3 $$ip > /dev/null && echo "✓ Worker $$WORKER_COUNT ($$ip)" || echo "✗ Worker $$WORKER_COUNT ($$ip) unreachable"; \
	done
# Quick cluster info
info:
	@echo "=== Cluster Information ==="
	@terraform -chdir=terraform output -json cluster_info | jq .
