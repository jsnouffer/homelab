# HELP
.PHONY: help

export PROXMOX_API_PASSWORD := $(shell cat ~/.proxmox-api-password)

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## packer init steps
	packer init .
	packer fmt .
	packer validate .

build: ## packer build
	packer build -var-file=variables.json .