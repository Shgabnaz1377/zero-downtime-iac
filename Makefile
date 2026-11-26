# Thin wrapper around Terraform and Ansible. Run `make help` for the list.
# Needs a POSIX shell (Linux, macOS or WSL): Ansible does not run natively on
# Windows.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

TF_DIR      := terraform
ANSIBLE_DIR := ansible
APP_DIR     := app
TERRAFORM   ?= terraform
PLAYBOOK    ?= ansible-playbook
PYTHON      ?= python3
TAG         ?=

export ANSIBLE_CONFIG := $(CURDIR)/$(ANSIBLE_DIR)/ansible.cfg

.PHONY: help init fmt validate plan apply inventory collections provision \
        deploy rollback status lint test destroy

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

## ---- Infrastructure -------------------------------------------------------

init: ## terraform init
	$(TERRAFORM) -chdir=$(TF_DIR) init

fmt: ## Format Terraform files in place
	$(TERRAFORM) -chdir=$(TF_DIR) fmt -recursive

validate: ## terraform fmt -check and validate (no backend, no credentials)
	$(TERRAFORM) -chdir=$(TF_DIR) fmt -check -recursive
	$(TERRAFORM) -chdir=$(TF_DIR) init -backend=false -input=false >/dev/null
	$(TERRAFORM) -chdir=$(TF_DIR) validate

plan: ## terraform plan, saved to terraform/tfplan
	$(TERRAFORM) -chdir=$(TF_DIR) plan -out=tfplan

apply: ## Apply the saved plan (or plan+apply interactively); writes the inventory
	@if [ -f $(TF_DIR)/tfplan ]; then \
	  $(TERRAFORM) -chdir=$(TF_DIR) apply tfplan && rm -f $(TF_DIR)/tfplan; \
	else \
	  $(TERRAFORM) -chdir=$(TF_DIR) apply; \
	fi

inventory: ## Re-render ansible/inventory/hosts.yml from Terraform state
	$(TERRAFORM) -chdir=$(TF_DIR) apply -target=local_file.ansible_inventory

destroy: ## Delete every cloud resource created by this project
	$(TERRAFORM) -chdir=$(TF_DIR) destroy

## ---- Configuration and releases --------------------------------------------

collections: ## Install the Ansible collections into ansible/collections
	cd $(ANSIBLE_DIR) && ansible-galaxy collection install -r requirements.yml -p collections

provision: collections ## Apply the OS baseline, Docker and Caddy (site.yml)
	cd $(ANSIBLE_DIR) && $(PLAYBOOK) site.yml

deploy: ## Blue/green release of an image tag: make deploy TAG=1.2.0
	@if [ -z "$(TAG)" ]; then echo "usage: make deploy TAG=<image tag>" >&2; exit 2; fi
	cd $(ANSIBLE_DIR) && $(PLAYBOOK) deploy.yml -e app_image_tag=$(TAG)

rollback: ## Switch traffic back to the previous colour
	cd $(ANSIBLE_DIR) && $(PLAYBOOK) rollback.yml

status: ## Show the live colour and what each colour runs
	cd $(ANSIBLE_DIR) && $(PLAYBOOK) status.yml

## ---- Quality -----------------------------------------------------------------

lint: ## yamllint, ansible-lint, terraform fmt/validate and tflint
	yamllint -s .
	ansible-lint
	$(MAKE) validate
	cd $(TF_DIR) && tflint --init --config=$(CURDIR)/.tflint.hcl
	cd $(TF_DIR) && tflint --recursive --config=$(CURDIR)/.tflint.hcl

test: ## Run the app's unit tests
	cd $(APP_DIR) && $(PYTHON) -m pytest
