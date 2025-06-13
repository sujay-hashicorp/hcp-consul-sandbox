include .env
export TF_VAR_cloud_provider
export TF_VAR_region
export TF_VAR_hcp_client_id
export TF_VAR_hcp_client_secret
export TF_VAR_hcp_project_id
export TF_VAR_hcp_hvn_id
export TF_VAR_hcp_cidr_block
export TF_VAR_consul_ent_license
export TF_VAR_consul_admin_token

.PHONY: init plan apply pre_destroy destroy

init:
	terraform -chdir=client-cluster init -upgrade

plan:
	terraform -chdir=client-cluster plan

apply:
	terraform -chdir=client-cluster apply -auto-approve

pre_destroy:
	@echo "Running consul leave before destroying instance..."
	-ssh -o StrictHostKeyChecking=no -i client-cluster/hcp-key.pem ubuntu@$(shell terraform -chdir=client-cluster output -raw instance_public_ip) 'consul leave || true'

destroy: pre_destroy
	terraform -chdir=client-cluster destroy -auto-approve