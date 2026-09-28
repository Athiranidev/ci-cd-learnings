# Docker + GitHub Actions — Push Image Automatically

## 1. Goal

Previously, Docker image publishing was done manually:

docker build → docker tag → docker push → Docker Hub

GitHub Actions can automate this process.

Final flow:

git push
    ↓
GitHub Actions
    ↓
Install dependencies
    ↓
Run tests
    ↓
Build Docker image
    ↓
Login to Docker Hub
    ↓
Push Docker image

---

## 2. Docker Hub Credentials

GitHub Actions needs credentials to authenticate with Docker Hub.

Create GitHub repository secrets:

DOCKERHUB_USERNAME
DOCKERHUB_TOKEN

The Docker Hub access token should be stored as a GitHub Secret.

Do not put the token directly in the workflow file.

---

## 3. Login to Docker Hub

GitHub Actions uses the Docker login action:

- name: Login to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}

The secrets are injected into the login step without exposing the token in the workflow logs.

---

## 4. Build the Docker Image

The image should be built using the same complete image reference that will later be pushed.

Example:

docker build -t athiranidev/ci-python-app:latest .

This creates:

athiranidev/ci-python-app:latest

---

## 5. Push the Docker Image

Push the same image reference:

docker push athiranidev/ci-python-app:latest

The build and push references must match.

Correct:

Build:
athiranidev/ci-python-app:latest

Push:
athiranidev/ci-python-app:latest

---

## 6. Image Tag Mismatch

An earlier CI run failed because the build and push used different image references.

Build:

docker build -t ci-python-app .

Created:

ci-python-app:latest

But push attempted:

docker push athiranidev/ci-python-app:latest

These are different image references.

ci-python-app:latest
        ≠
athiranidev/ci-python-app:latest

Docker therefore reported:

An image does not exist locally with the tag:
athiranidev/ci-python-app:latest

---

## 7. Corrected Build

The build was changed to:

docker build -t athiranidev/ci-python-app:latest .

Now the push uses the exact same reference:

docker push athiranidev/ci-python-app:latest

Therefore:

Build image
    ↓
athiranidev/ci-python-app:latest
    ↓
Push
    ↓
Docker Hub

---

## 8. Complete GitHub Actions Flow

The relevant workflow steps are:

- name: Run tests
  run: pytest

- name: Build Docker image
  run: docker build -t athiranidev/ci-python-app:latest .

- name: Login to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}

- name: Push Docker image
  run: docker push athiranidev/ci-python-app:latest

Tests run before the Docker image is published.

If the test step fails, later normal steps do not run.

---

## 9. Final Mental Model

Git push
    ↓
GitHub Actions
    ↓
Checkout
    ↓
Install dependencies
    ↓
Run tests
    ↓
Build Docker image
    ↓
Authenticate with Docker Hub
    ↓
Push Docker image
    ↓
Docker Hub

Core principle:

Test first → Build → Authenticate → Push

Important:

The image reference used during build must match the image reference used during push.

Example:

athiranidev/ci-python-app:latest

---

## 10. Key Concepts

GitHub Secret
→ Securely stores sensitive values such as Docker Hub credentials.

docker/login-action
→ GitHub Action used to authenticate with Docker Hub.

docker build
→ Builds the Docker image on the GitHub Actions runner.

docker push
→ Pushes the built image from the runner to Docker Hub.

Image reference
→ Complete Docker image name and tag, such as:

athiranidev/ci-python-app:latest

The GitHub Actions runner is temporary, so the Docker image created during the job is not automatically preserved after the job. Pushing it to Docker Hub stores it remotely.