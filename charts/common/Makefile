# HELP
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install-dependencies: ## install dependencies
	- helm plugin install https://github.com/chartmuseum/helm-push
	helm repo add local https://chartmuseum.jsnouff.net

push: ## push helm chart
	helm cm-push . local
