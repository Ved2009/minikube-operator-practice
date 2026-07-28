cat > README.md << 'README_EOF'
# minikube-operator-practice

A hands-on exercise in the core "operator" workflow: build a Docker image from an open-source repo's source, then deploy it to a local Kubernetes cluster (minikube) via Helm, all driven through a Makefile.

## What this does

- make build - calls scripts/build.sh, which runs docker build against a given repo/context directory.
- make deploy - starts minikube if needed, loads the built image into the cluster's internal registry, then runs helm upgrade --install to deploy it.
- make status / make logs / make clean - day-2 operator commands for checking on and tearing down the deployment.

This repo targets Redis as the practice app, using the official Docker Library packaging repo (github.com/docker-library/redis) rather than the raw Redis source repo - see notes below on why.

## Usage

    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm pull bitnami/redis --untar --untardir ./charts
    git clone https://github.com/docker-library/redis.git redis-official
    make build IMAGE_NAME=my-redis IMAGE_TAG=v3 CONTEXT_DIR=./redis-official/7.4/debian
    make deploy IMAGE_NAME=my-redis IMAGE_TAG=v3
    make status
    make logs
    make clean

## Design notes

- scripts/build.sh validates the context directory and Dockerfile exist before building, and fails loudly with a clear message if not.
- deploy target overrides the chart's image.registry/image.repository/image.tag to point at the locally built image rather than pulling from a public registry, and sets pullPolicy=IfNotPresent.
- allowInsecureImages=true is required because this chart (Bitnami's) validates images against a known catalog by default and refuses to deploy unrecognized ones.
- commonConfiguration override strips two loadmodule directives (RediSearch, ReJSON) baked into the default chart config - those modules only exist in Bitnami's own image, not a vanilla Redis build, and caused the container to abort on startup without this override.
README_EOF
