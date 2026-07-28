#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="${1:?Usage: build.sh <image-name> <tag> [context-dir]}"
IMAGE_TAG="${2:-dev}"
CONTEXT_DIR="${3:-.}"

if [ ! -d "${CONTEXT_DIR}" ]; then
  echo "Error: context directory '${CONTEXT_DIR}' does not exist." >&2
  exit 1
fi

if [ ! -f "${CONTEXT_DIR}/Dockerfile" ]; then
  echo "Error: no Dockerfile found in '${CONTEXT_DIR}'." >&2
  exit 1
fi

echo ">> Building ${IMAGE_NAME}:${IMAGE_TAG} from ${CONTEXT_DIR}"
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" "${CONTEXT_DIR}"
echo ">> Build complete: ${IMAGE_NAME}:${IMAGE_TAG}"
