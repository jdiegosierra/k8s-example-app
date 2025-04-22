.PHONY: kind-create kind-delete deploy-prometheus deploy-grafana deploy-revolut-app clean install-deps help restart

# Variables
KIND_CLUSTER_NAME ?= revolut-cluster
PROMETHEUS_NAMESPACE ?= monitoring
GRAFANA_NAMESPACE ?= monitoring
REVOLUT_APP_NAMESPACE ?= revolut-app

# Ayuda
help:
	@echo "Comandos disponibles:"
	@echo "  make help              - Muestra esta ayuda"
	@echo "  make install-deps      - Instala las dependencias necesarias (kind, kubectl, helm)"
	@echo "  make kind-create       - Crea un cluster Kind local"
	@echo "  make kind-delete       - Elimina el cluster Kind"
	@echo "  make deploy-prometheus - Despliega Prometheus y Grafana en el cluster"
	@echo "  make deploy-revolut-app - Despliega la aplicación revolut-app en el cluster"
	@echo "  make access-grafana    - Muestra información de acceso a Grafana"
	@echo "  make access-revolut-app - Muestra información de acceso a revolut-app"
	@echo "  make clean             - Limpia el entorno (elimina el cluster)"
	@echo "  make all               - Ejecuta el proceso completo (crear cluster y desplegar)"
	@echo "  make restart           - Reinicia el proceso completo (limpia y ejecuta)"
	@echo ""
	@echo "Variables de configuración:"
	@echo "  KIND_CLUSTER_NAME      - Nombre del cluster Kind (default: revolut-cluster)"
	@echo "  PROMETHEUS_NAMESPACE   - Namespace para Prometheus (default: monitoring)"
	@echo "  GRAFANA_NAMESPACE      - Namespace para Grafana (default: monitoring)"
	@echo "  REVOLUT_APP_NAMESPACE  - Namespace para revolut-app (default: revolut-app)"

# Instalar dependencias
install-deps:
	@echo "Instalando dependencias..."
	brew install kind kubectl helm || (echo "Error: Homebrew no está instalado. Por favor, instala Homebrew primero: https://brew.sh/" && exit 1)

# Crear cluster Kind
kind-create:
	@echo "Creando cluster Kind..."
	kind create cluster --name $(KIND_CLUSTER_NAME)

# Eliminar cluster Kind
kind-delete:
	@echo "Eliminando cluster Kind..."
	kind delete cluster --name $(KIND_CLUSTER_NAME)

# Crear namespace para monitoring
create-namespace:
	@echo "Creando namespace para monitoring..."
	kubectl create namespace $(PROMETHEUS_NAMESPACE) || true

# Instalar Prometheus usando Helm
deploy-prometheus: create-namespace
	@echo "Instalando Prometheus..."
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install prometheus prometheus-community/kube-prometheus-stack \
		--namespace $(PROMETHEUS_NAMESPACE) \
		--set prometheus.service.type=NodePort \
		--set prometheus.service.nodePort=30000 \
		--set grafana.service.type=NodePort \
		--set grafana.service.nodePort=30001

# Crear namespace para revolut-app
create-revolut-namespace:
	@echo "Creando namespace para revolut-app..."
	kubectl create namespace $(REVOLUT_APP_NAMESPACE) || true

# Desplegar revolut-app
deploy-revolut-app: create-revolut-namespace
	@echo "Desplegando revolut-app..."
	helm install revolut-app ./charts/revolut-app \
		--namespace $(REVOLUT_APP_NAMESPACE) \
		--set service.type=NodePort \
		--set service.nodePort=30002

# Acceder a Grafana
access-grafana:
	@echo "Accediendo a Grafana..."
	@echo "Usuario: admin"
	@echo "Contraseña: prom-operator"
	@echo "URL: http://localhost:30001"

# Acceder a revolut-app
access-revolut-app:
	@echo "Accediendo a revolut-app..."
	@echo "URL: http://localhost:30002"

# Limpiar todo
clean: kind-delete

# Comando por defecto
all: kind-create deploy-revolut-app

# Reiniciar todo
restart: clean all
