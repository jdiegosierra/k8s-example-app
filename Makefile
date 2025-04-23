.PHONY: help create-cluster deploy clean install-postgres-operator deploy-postgresql

# Variables
CLUSTER_NAME ?= revolut-cluster
HELM_CHART_PATH ?= helm/app
KIND_CONFIG_PATH ?= scripts/kind-config.yaml
POSTGRES_OPERATOR_NAMESPACE ?= postgres-operator
POSTGRES_MANIFEST_PATH ?= helm/postgres/postgresql.yaml

help: ## Muestra esta ayuda
	@echo 'Uso:'
	@echo '  make <target>'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

create-cluster: ## Crea un nuevo cluster Kind
	@echo "Creando cluster Kind..."
	@kind create cluster --name $(CLUSTER_NAME) --config=$(KIND_CONFIG_PATH)
	@echo "Cluster creado exitosamente"

deploy: ## Despliega el Helm chart en el cluster
	@echo "Desplegando Helm chart..."
	@helm upgrade --install revolut-app $(HELM_CHART_PATH) --namespace default --create-namespace
	@echo "Helm chart desplegado exitosamente"

clean: ## Elimina el cluster Kind
	@echo "Eliminando cluster Kind..."
	@kind delete cluster --name $(CLUSTER_NAME)
	@echo "Cluster eliminado exitosamente"

install-postgres-operator: ## Instala el Postgres Operator en el cluster
	@echo "Añadiendo repositorio de Postgres Operator..."
	@helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator
	@echo "Instalando Postgres Operator..."
	@helm install postgres-operator postgres-operator-charts/postgres-operator --namespace $(POSTGRES_OPERATOR_NAMESPACE) --create-namespace
	@echo "Postgres Operator instalado exitosamente"

deploy-postgresql: ## Despliega el manifiesto de PostgreSQL
	@echo "Desplegando manifiesto de PostgreSQL..."
	@kubectl apply -f $(POSTGRES_MANIFEST_PATH)
	@echo "Manifiesto de PostgreSQL desplegado exitosamente" 