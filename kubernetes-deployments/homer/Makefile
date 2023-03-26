# HELP
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## install chart
	helm install homer . -n homer --create-namespace

upgrade: ## upgrade release
	helm upgrade homer . -n homer

uninstall: ## uninstall chart
	helm uninstall -n homer homer
