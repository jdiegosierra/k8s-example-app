.PHONY: install-dependencies tests start-dev-env stop-dev-env start-cloud-env stop-cloud-env install-postgres-operator deploy-postgresql build-image load-image deploy-app

KIND_VERSION ?= 0.23.0
HELM_VERSION ?= 3.17.2
KUBECTL_VERSION ?= 1.30.7
DOCKER_VERSION ?= 27.5.1
DENO_VERSION ?= 2.2.11
POSTGRES_OPERATOR_VERSION ?= 0.23.2
POSTGRES_CHART_VERSION ?= 0.3.0

DEPENDENCIES := kind helm kubectl docker deno
CLUSTER_NAME ?= local
HELM_CHART_PATH ?= charts/app
POSTGRES_SECRET_PATH ?= charts/postgres/secret.yaml
LOCAL_IMAGE_NAME ?= app
LOCAL_IMAGE_TAG ?= latest
APP_PORT ?= $(shell yq '.port' $(HELM_CHART_PATH)/values.yaml)

install-dependencies:
	@echo "The following dependencies will be installed with fixed versions:"
	@echo "- kind: $(KIND_VERSION)"
	@echo "- helm: $(HELM_VERSION)"
	@echo "- kubectl: $(KUBECTL_VERSION)"
	@echo "- docker: $(DOCKER_VERSION)"
	@echo "- deno: $(DENO_VERSION)"
	@echo "\nDo you want to proceed with the installation? (y/n)"
	@read -p "Answer: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		for dep in $(DEPENDENCIES); do \
			if ! command -v $$dep >/dev/null 2>&1; then \
				echo "Installing $$dep..."; \
				if [ "$$dep" = "deno" ]; then \
					curl -fsSL https://deno.land/x/install/install.sh | sh -s v$(DENO_VERSION); \
				elif [ "$$dep" = "kind" ]; then \
					curl -Lo ./kind https://kind.sigs.k8s.io/dl/v$(KIND_VERSION)/kind-darwin-amd64 && \
					chmod +x ./kind && \
					mv ./kind /usr/local/bin/kind; \
				elif [ "$$dep" = "helm" ]; then \
					curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
					chmod 700 get_helm.sh && \
					./get_helm.sh --version v$(HELM_VERSION) && \
					rm get_helm.sh; \
				elif [ "$$dep" = "kubectl" ]; then \
					curl -LO "https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/darwin/amd64/kubectl" && \
					chmod +x kubectl && \
					mv kubectl /usr/local/bin/kubectl; \
				else \
					brew install $$dep@$(DOCKER_VERSION); \
				fi \
			else \
				echo "$$dep is already installed."; \
			fi \
		done \
	else \
		echo "Installation cancelled."; \
		exit 1; \
	fi

tests:
	@echo "Running application tests..."
	@cd app && deno task test

start-dev-env:
	@echo "Starting development environment..."
	@docker compose -f scripts/local-environment/docker-compose.dev.yml up

stop-dev-env:
	@echo "Stopping development environment..."
	@docker compose -f scripts/local-environment/docker-compose.dev.yml down

start-cloud-env:
	@echo "Simulating cloud environment setup. This process will take a few minutes..."
	@kind create cluster --name $(CLUSTER_NAME)
	@make build-image
	@make load-image
	@make build-image
	@make install-postgres-operator
	@echo "Waiting for PostgreSQL operator to be ready..."
	@kubectl wait --for=condition=Available deployment/postgres-operator-cloudnative-pg -n default --timeout=300s
	@kubectl apply -f $(POSTGRES_SECRET_PATH)
	@make deploy-postgresql
	@echo "Waiting for PostgreSQL cluster to be ready..."
	@kubectl wait --for=condition=Ready cluster/cluster -n default --timeout=300s
	@make deploy-app
	@echo "Waiting for application to be ready..."
	@kubectl wait --for=condition=Available deployment/app -n default --timeout=300s
	@kubectl port-forward svc/app $(APP_PORT):$(APP_PORT)

stop-cloud-env:
	@echo "Stoping cloud environment..."
	@kind delete cluster --name $(CLUSTER_NAME)

install-postgres-operator:
	@echo "Installing PostgreSQL operator version $(POSTGRES_OPERATOR_VERSION)..."
	@helm repo add cloudnative-pg https://cloudnative-pg.io/charts/
	@helm upgrade --install postgres-operator cloudnative-pg/cloudnative-pg --version $(POSTGRES_OPERATOR_VERSION)

deploy-postgresql:
	@echo "Deploying PostgreSQL chart version $(POSTGRES_CHART_VERSION)..."
	@helm repo add cloudnative-pg https://cloudnative-pg.io/charts/
	@helm upgrade --install cluster cloudnative-pg/cluster --set cluster.superuserSecret=cluster-superuser --set cluster.instances=1 --version $(POSTGRES_CHART_VERSION)

build-image:
	@echo "Building Docker image..."
	@docker build -t $(LOCAL_IMAGE_NAME):$(LOCAL_IMAGE_TAG) .

load-image:
	@echo "Loading image into Kind cluster..."
	@kind load docker-image $(LOCAL_IMAGE_NAME):$(LOCAL_IMAGE_TAG) --name $(CLUSTER_NAME)

deploy-app:
	@echo "Deploying app to Kind cluster..."
	@helm upgrade --install app $(HELM_CHART_PATH)
