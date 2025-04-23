.PHONY: start-local-env delete-local-env deploy-app install-postgres-operator deploy-postgresql install-dependencies


DEPENDENCIES := kind helm kubectl docker
CLUSTER_NAME ?= revolut-cluster
KIND_CONFIG_PATH ?= local-env/kind-config.yaml
HELM_CHART_PATH ?= charts/app
POSTGRES_SECRET_PATH ?= charts/postgres/secret.yaml


install-dependencies:
	@echo "The following dependencies will be installed:"
	@for dep in $(DEPENDENCIES); do \
		echo "- $$dep"; \
	done
	@echo "\nDo you want to proceed with the installation? (y/n)"
	@read -p "Answer: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		for dep in $(DEPENDENCIES); do \
			if ! command -v $$dep >/dev/null 2>&1; then \
				echo "Installing $$dep..."; \
				brew install $$dep; \
			else \
				echo "$$dep is already installed."; \
			fi \
		done \
	else \
		echo "Installation cancelled."; \
		exit 1; \
	fi

start-local-env:
	@echo "Starting local environment setup. This process will take a few minutes..."
	@kind create cluster --name $(CLUSTER_NAME) --config=$(KIND_CONFIG_PATH)
	@make install-postgres-operator
	@sleep 30
	@kubectl apply -f $(POSTGRES_SECRET_PATH)
	@make deploy-postgresql
	@sleep 30
	@make deploy-app
	@sleep 30
	@kubectl port-forward svc/revolut-app 8000:8000

delete-local-env:
	@kind delete cluster --name $(CLUSTER_NAME)

install-postgres-operator:
	@helm repo add cloudnative-pg https://cloudnative-pg.io/charts/
	@helm upgrade --install my-cloudnative-pg cloudnative-pg/cloudnative-pg --version 0.23.2

deploy-postgresql:
	@helm repo add cloudnative-pg https://cloudnative-pg.io/charts/
	@helm upgrade --install cluster cloudnative-pg/cluster --set cluster.superuserSecret=cluster-superuser --set cluster.instances=1 --version 0.3.0

deploy-app:
	@helm upgrade --install revolut-app $(HELM_CHART_PATH)
