.PHONY: help
help: ## Display this help message
	@grep -E '^[a-zA-Z_-]+:.*## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Build the necessary docker images
	docker build --pull --build-arg USER_ID="$(shell id -u)" --build-arg GROUP_ID="$(shell id -g)" -t blog .

.PHONY: shell
shell: ## Run a shell with mkdocs/python env
	docker run --rm -it -v "$(shell pwd):$(shell pwd)" -w "$(shell pwd)" blog bash

.PHONY: serve
serve: ## Serve mkdocs website locally on http://localhost:8000/
	docker run --rm -it -v "$(shell pwd):$(shell pwd)" -w "$(shell pwd)" -p 8000:8000 blog \
	mkdocs serve -a 0.0.0.0:8000

.PHONY: generate
generate: ## Generate the static website assets
	docker run --rm -v "$(shell pwd):$(shell pwd)" -w "$(shell pwd)" blog \
	mkdocs build -d public

.PHONY: deploy
deploy: ## Upload the site content
	rsync -av public/ maurinh@ssh.cluster023.hosting.ovh.net:vmtech/
