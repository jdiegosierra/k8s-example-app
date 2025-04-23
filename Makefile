.PHONY: start-local-env delete-local-env deploy-app install-postgres-operator deploy-postgresql


CLUSTER_NAME ?= revolut-cluster
KIND_CONFIG_PATH ?= scripts/kind-config.yaml
HELM_CHART_PATH ?= charts/app


start-local-env:
	@kind create cluster --name $(CLUSTER_NAME) --config=$(KIND_CONFIG_PATH)
	@make install-postgres-operator
	@sleep 60
	@make deploy-postgresql

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
