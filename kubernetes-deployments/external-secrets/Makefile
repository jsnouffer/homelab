# HELP
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## install chart
	helm install external-secrets . -n external-secrets --create-namespace

install-init: ## install chart
	helm install external-secrets . -n external-secrets --create-namespace --set external-secrets.initialInstall=true

upgrade: ## upgrade release
	helm upgrade external-secrets . -n external-secrets --set external-secrets.initialInstall=false

uninstall: ## uninstall chart
	helm uninstall -n external-secrets external-secrets
