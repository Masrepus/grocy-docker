.PHONY: grocy-app grocy-nginx

IMAGE_COMMIT := $(shell git rev-parse --short HEAD)
IMAGE_TAG := "libpod-issue-5631"

build: grocy-pod grocy-app grocy-nginx
	podman run --detach --name grocy-app --pod grocy --read-only grocy-app:${IMAGE_TAG}
	podman run --detach --name grocy-nginx --pod grocy --read-only-tmpfs grocy-nginx:${IMAGE_TAG}

grocy-pod:
	podman pod rm -f grocy || true
	podman pod create --name grocy --publish 8000:80

grocy-app:
	podman image exists $@:${IMAGE_TAG} || buildah bud -f Dockerfile-grocy -t $@:${IMAGE_TAG} --build-arg GITHUB_API_TOKEN=${GITHUB_API_TOKEN} .

grocy-nginx:
	podman image exists $@:${IMAGE_TAG} || buildah bud -f Dockerfile-grocy-nginx -t $@:${IMAGE_TAG} .
