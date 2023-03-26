# HELP
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## install chart
	helm install contour . -n contour --create-namespace

upgrade: ## upgrade release
	helm upgrade contour . -n contour

uninstall: ## uninstall chart
	helm uninstall -n contour contour
