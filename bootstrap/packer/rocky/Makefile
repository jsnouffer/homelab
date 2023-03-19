# HELP
.PHONY: help

export PROXMOX_API_PASSWORD := $(shell cat ~/.proxmox-api-password)
export ROCKY_USER_PASSWORD := $(shell cat ~/.rocky-user-password)

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

validate: ## packer validate steps
	packer init .
	packer fmt .
	packer validate -var-file=variables.json .

build: ## packer build
	packer build -var-file=variables.json .