# HELP
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## install chart
	helm install cert-manager . -n cert-manager --create-namespace

upgrade: ## upgrade release
	helm upgrade cert-manager . -n cert-manager

uninstall: ## uninstall chart
	helm uninstall -n cert-manager cert-manager
