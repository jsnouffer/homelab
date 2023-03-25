# HELP
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## install chart
	helm install sealed-secrets . -n kube-system

upgrade: ## upgrade release
	helm upgrade sealed-secrets . -n kube-system

uninstall: ## uninstall chart
	helm uninstall -n kube-system sealed-secrets
