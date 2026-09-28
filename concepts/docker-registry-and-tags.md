# Docker Registry and Image Tags

## 1. Container Registry

A container registry is a remote storage system for Docker/container images.

Docker Hub is a public container registry.

Purpose:

- Store Docker images
- Share images between machines
- Allow servers/other developers to pull the same image
- Avoid rebuilding the image everywhere

Mental model:

Build once → Test → Store in Registry → Pull → Run

---

## 2. Docker Hub

Docker Hub is a container registry provided by Docker.

Example repository:

athiranidev/ci-python-app

An image reference normally looks like:

USERNAME/IMAGE:TAG

Example:

athiranidev/ci-python-app:latest

---

## 3. Docker Image Tag

A tag is a name/reference attached to an image.

Examples:

latest
v1
v2
dev
testing

Example:

athiranidev/ci-python-app:v1

The tag does not create a new image.

Example:

docker tag athiranidev/ci-python-app:latest athiranidev/ci-python-app:v1

Both tags can point to the same image.

---

## 4. `latest` Is Just a Tag

`latest` does not automatically mean "newest image".

It is simply a tag named `latest`.

For example:

athiranidev/ci-python-app:latest
athiranidev/ci-python-app:v1

Both are references that can point to images.

---

## 5. Build an Image

Example:

docker build -t ci-python-app .

This creates a local Docker image.

---

## 6. Tag an Image for Docker Hub

Example:

docker tag ci-python-app:latest athiranidev/ci-python-app:latest

Create a version tag:

docker tag athiranidev/ci-python-app:latest athiranidev/ci-python-app:v1

`docker tag` does not rebuild or copy the image.

Multiple tags can point to the same image.

---

## 7. Push an Image

Push an image/tag from the local machine to Docker Hub:

docker push athiranidev/ci-python-app:v1

General flow:

Local image → Docker Hub

The registry may report:

Layer already exists

This means Docker Hub already has that layer, so it does not need to upload it again.

---

## 8. Pull an Image

Download an image from Docker Hub:

docker pull athiranidev/ci-python-app:v1

General flow:

Docker Hub → Local Docker environment

`docker pull` downloads the image. It does not work like `git pull`, which also performs Git integration/merging.

---

## 9. Local Image vs Remote Image

`docker images` shows images/tags available locally.

Example:

docker images | grep ci-python-app

This does NOT prove that a tag exists on Docker Hub.

To inspect a remote image:

docker manifest inspect athiranidev/ci-python-app:v1

If the manifest exists, the tag exists in the registry.

---

## 10. Local Tag vs Remote Tag

A tag can exist locally but not in Docker Hub.

Example:

Local:

athiranidev/ci-python-app:v1

Docker Hub:

v1 does not exist

After:

docker push athiranidev/ci-python-app:v1

The remote tag exists as well.

Mental model:

Local Docker:
    image:v1

        |
        | docker push
        ↓

Docker Hub:
    image:v1

---

## 11. Image Digest

Docker can identify image content using a digest.

Example:

sha256:49892784841474a58bae18df89b555ca16366d2565af7bf110447390ef9a1994

Tags such as `latest` and `v1` are human-readable references.

The digest identifies the image content.

Multiple tags can point to the same image digest.

---

## 12. Manifest Size vs Image Size

Docker commands may show different sizes.

For example:

v1: digest: sha256:... size: 856

The `856` value is the size of the image index/manifest metadata.

It is NOT the size of the actual Docker image.

The actual image/layer storage can be much larger, for example around 214 MB.

Therefore:

Manifest size ≠ Image size

---

## 13. Important Commands

Build:

docker build -t ci-python-app .

Tag:

docker tag ci-python-app:latest athiranidev/ci-python-app:v1

Login:

docker login

Push:

docker push athiranidev/ci-python-app:v1

Pull:

docker pull athiranidev/ci-python-app:v1

List local images:

docker images

Inspect remote manifest:

docker manifest inspect athiranidev/ci-python-app:v1

---

## 14. Practical Flow

Build:

docker build -t ci-python-app .

Tag:

docker tag ci-python-app:latest athiranidev/ci-python-app:v1

Push:

docker push athiranidev/ci-python-app:v1

Verify remote tag:

docker manifest inspect athiranidev/ci-python-app:v1

Pull:

docker pull athiranidev/ci-python-app:v1

---

## Core Mental Model

Docker image = packaged application

Docker tag = reference/name for an image

Docker registry = remote storage for images

Docker Hub = a container registry

docker build = create image locally

docker tag = create another reference to the image

docker push = local → registry

docker pull = registry → local

docker manifest inspect = inspect a remote image reference

Image digest = identifier for image content

Important distinction:

docker images
→ What exists locally?

docker manifest inspect IMAGE:TAG
→ Does this image/tag exist in the remote registry?

Core workflow:

Build → Tag → Push → Registry → Pull → Run