IMAGE_NAME    ?= my-redis
IMAGE_TAG     ?= dev
CONTEXT_DIR   ?= .
NAMESPACE     ?= default
RELEASE_NAME  ?= redis-dev
CHART_PATH    ?= ./charts/redis

.PHONY: minikube-start build load-image deploy status logs clean

minikube-start:
	minikube status >/dev/null 2>&1 || minikube start --driver=docker --cpus=4 --memory=3600mb

build:
	./scripts/build.sh $(IMAGE_NAME) $(IMAGE_TAG) $(CONTEXT_DIR)

load-image: build
	minikube image load $(IMAGE_NAME):$(IMAGE_TAG)

deploy: minikube-start load-image
	helm upgrade --install $(RELEASE_NAME) $(CHART_PATH) --namespace $(NAMESPACE) --create-namespace --set image.registry=docker.io --set image.repository=library/$(IMAGE_NAME) --set image.tag=$(IMAGE_TAG) --set image.pullPolicy=IfNotPresent --set global.security.allowInsecureImages=true --set-string commonConfiguration="appendonly yes"

status:
	kubectl get pods,svc -n $(NAMESPACE) -l app.kubernetes.io/instance=$(RELEASE_NAME)

logs:
	kubectl logs -n $(NAMESPACE) -l app.kubernetes.io/instance=$(RELEASE_NAME) --tail=100 -f

clean:
	helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE) --ignore-not-found
	minikube image rm $(IMAGE_NAME):$(IMAGE_TAG) || true
