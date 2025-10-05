## Makefile shortcuts for Terraform with built-in prompt and var-file reminder.
## Usage:
##   make plan        # uses default var-file env/dev/terraform.tfvars
##   make apply       # uses default var-file env/dev/terraform.tfvars
##   make destroy     # uses default var-file env/dev/terraform.tfvars
## You can override var-file with: make apply VARFILE=env/prod/terraform.tfvars

.PHONY: plan apply destroy

DEFAULT_VARFILE := env/dev/terraform.tfvars
VARFILE ?= $(DEFAULT_VARFILE)

plan:
	@echo "Reminder: run terraform with -var-file to select environment (default: $(DEFAULT_VARFILE))"
	@read -r "-p?Proceed with 'terraform plan -var-file=$(VARFILE)'? [Y/n] " ans; \
	if [ "$$ans" = "n" ] || [ "$$ans" = "N" ]; then echo "Aborted"; exit 1; fi; \
	terraform plan -var-file=$(VARFILE)

apply:
	@echo "Reminder: run terraform with -var-file to select environment (default: $(DEFAULT_VARFILE))"
	@read -r "-p?Proceed with 'terraform apply -var-file=$(VARFILE) -auto-approve'? [Y/n] " ans; \
	if [ "$$ans" = "n" ] || [ "$$ans" = "N" ]; then echo "Aborted"; exit 1; fi; \
	terraform apply -var-file=$(VARFILE) -auto-approve

destroy:
	@echo "Reminder: run terraform with -var-file to select environment (default: $(DEFAULT_VARFILE))"
	@read -r "-p?Proceed with 'terraform destroy -var-file=$(VARFILE) -auto-approve'? [Y/n] " ans; \
	if [ "$$ans" = "n" ] || [ "$$ans" = "N" ]; then echo "Aborted"; exit 1; fi; \
	terraform destroy -var-file=$(VARFILE) -auto-approve
