# Docker + CI Integration

## What We Learned

We already know how to build a Docker image locally:

    docker build -t ci-python-app .

We now used the same idea inside GitHub Actions.

The purpose of this exercise is to verify that the application can be built into a Docker image automatically in CI.

---

## Dockerfile

Our project uses a simple Dockerfile:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .
    RUN pip install -r requirements.txt

    COPY app.py .

    CMD ["python3", "app.py"]

The Dockerfile defines how the Docker image is built.

---

## Local Build

We first tested the Dockerfile locally:

    docker build -t ci-python-app .

The image was successfully created:

    ci-python-app:latest

This confirmed that the Dockerfile works before adding it to CI.

---

## Docker Build in CI

GitHub Actions can execute Docker commands on the CI runner.

Our Build step is:

    - name: Build Docker image
      run: docker build -t ci-python-app .

The GitHub Actions runner executes the same Docker build command that we tested locally.

---

## CI Flow

    Developer
        ↓
    git push
        ↓
    GitHub repository
        ↓
    GitHub Actions
        ↓
    Runner
        ↓
    Checkout code
        ↓
    Install dependencies
        ↓
    Run tests
        ↓
    Docker build
        ↓
    Docker image created
        ↓
    CI result

---

## Important Concept

The Docker image created during the CI job exists on the temporary GitHub Actions runner.

For this exercise, we only verify that the Docker image can be built successfully.

We are NOT storing or pushing the image yet.

After the CI job finishes, the temporary runner is discarded, so the image is not preserved.

---

## Artifact vs Docker Image

An artifact is a file or collection of files that can be preserved from a workflow run.

A Docker image is a container image produced by `docker build`.

They are different things.

For this exercise:

    Docker build
        ↓
    Docker image
        ↓
    Verify build
        ↓
    CI job finishes

We do not upload the Docker image as an artifact.

---

## What Comes Later

If a Docker image needs to be preserved and used outside the CI runner, it can be pushed to a container registry.

General flow:

    Dockerfile
        ↓
    docker build
        ↓
    Docker image
        ↓
    Tag
        ↓
    Container registry
        ↓
    Pull and use the image

Container registries will be studied separately.

---

## Key Mental Model

CI does not automatically create a Docker image.

The workflow contains a command:

    docker build -t ci-python-app .

The runner executes that command.

Therefore:

    GitHub Actions
        ↓
    Runner
        ↓
    Docker command
        ↓
    Docker image

The main purpose of this exercise is to connect our existing Docker knowledge with CI automation.