# HELP
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## install chart
	helm install kubeapps . -n kubeapps --create-namespace

upgrade: ## upgrade release
	helm upgrade kubeapps . -n kubeapps

uninstall: ## uninstall chart
	helm uninstall -n kubeapps kubeapps
