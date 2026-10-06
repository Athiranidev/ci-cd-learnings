# End-to-End CI/CD Pipeline with GitHub Actions, Docker, Docker Hub and AWS EC2

## 1. Project Overview

This project implements a complete CI/CD pipeline for a Python Flask application.

The pipeline automatically:

1. Tests the application with multiple Python versions.
2. Builds a Docker image.
3. Pushes the Docker image to Docker Hub.
4. Deploys the latest image to an AWS EC2 server after changes are merged into `main`.
5. Runs the updated Flask application inside a Docker container on EC2.

---

## 2. Architecture

Developer
    ↓
Feature Branch
    ↓
Pull Request
    ↓
GitHub Actions CI
    ├── Python 3.11 tests
    ├── Python 3.12 tests
    └── Python 3.13 tests
            ↓
       Docker Build
            ↓
       Docker Hub
            ↓
   PR merged into main
            ↓
   GitHub Actions CD
            ↓
       SSH → AWS EC2
            ↓
   Pull latest Docker image
            ↓
   Stop old container
            ↓
   Remove old container
            ↓
   Start new container
            ↓
     Flask Application

---

## 3. CI/CD Workflow

### CI

CI means Continuous Integration.

When code is pushed or a Pull Request is created:

- GitHub Actions starts the workflow.
- The repository is checked out.
- Python 3.11, 3.12 and 3.13 are tested using a matrix strategy.
- Dependencies are installed.
- Automated tests are executed.
- After all tests pass, the Docker image is built.
- The image is pushed to Docker Hub.

### CD

CD means Continuous Deployment in this project.

Deployment happens only when the workflow is triggered by a push/update to the `main` branch.

The deployment job:

1. Connects to EC2 using SSH.
2. Pulls the latest Docker image from Docker Hub.
3. Stops the existing container.
4. Removes the existing container.
5. Starts a new container using the latest image.

---

## 4. GitHub Actions Job Structure

The workflow contains three logical stages:

### Test

The test job uses a matrix:

- Python 3.11
- Python 3.12
- Python 3.13

The same test job runs independently for each Python version.

### Build

The build job uses:

`needs: test`

Therefore, the Docker image is built only after the complete test matrix succeeds.

The image is tagged:

`athiranidev/ci-python-app:latest`

The image is then pushed to Docker Hub.

### Deploy

The deploy job uses:

`needs: build`

Therefore, deployment starts only after the build job succeeds.

The deployment condition is:

`if: github.event_name == 'push' && github.ref == 'refs/heads/main'`

This means deployment happens only for a push/update to the `main` branch.

Pull Requests do not automatically deploy to EC2.

---

## 5. Pull Request Flow

Development is done on a feature branch.

Example:

main
  │
  └── cd-ec2-deployment
          │
          └── git push
                  ↓
              Pull Request
                  ↓
             CI validation
                  ↓
                Merge
                  ↓
           Remote main updated
                  ↓
            Push event on main
                  ↓
            CI + CD deployment

A PR merge updates the remote `main` branch.

This creates the `push` event that satisfies the deployment condition.

No manual:

`git push origin main`

is required after the PR is merged.

---

## 6. Local main vs Remote main

After a PR is merged on GitHub, the remote `main` branch contains the merged changes.

The local `main` branch may still be behind.

To synchronize the local repository:

`git switch main`

`git pull origin main`

`git pull` downloads the changes from the remote repository.

A new `git push` is not required because the merge has already updated the remote `main`.

---

## 7. Docker

Docker is used to package and run the Flask application.

Dockerfile:

FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python3", "app.py"]

The image is built using:

`docker build -t athiranidev/ci-python-app:latest .`

The image is pushed to Docker Hub by GitHub Actions.

---

## 8. Docker Hub

Docker Hub acts as the container image registry between CI and the EC2 server.

Flow:

GitHub Actions
      ↓
Build Docker image
      ↓
Push image
      ↓
Docker Hub
      ↓
EC2 pulls image

The deployment uses:

`athiranidev/ci-python-app:latest`

---

## 9. AWS EC2

The application runs on an Ubuntu EC2 instance.

Docker is installed on the EC2 server.

The deployment commands executed remotely are:

`sudo docker pull athiranidev/ci-python-app:latest`

`sudo docker stop ci-cd-flask-app || true`

`sudo docker rm ci-cd-flask-app || true`

`sudo docker run -d --name ci-cd-flask-app -p 5000:5000 athiranidev/ci-python-app:latest`

The application is exposed on port `5000`.

---

## 10. SSH Deployment

GitHub Actions uses:

`appleboy/ssh-action`

This action establishes an SSH connection from the GitHub Actions runner to the EC2 server.

The connection uses GitHub Secrets:

- `EC2_HOST`
- `EC2_USERNAME`
- `EC2_SSH_KEY`

The private SSH key is stored as a GitHub Actions secret and is not committed to the repository.

The action allows GitHub Actions to execute Docker commands directly on the EC2 server.

---

## 11. GitHub Secrets

The project uses GitHub Actions Secrets for sensitive values.

Secrets used:

- `DEMO_SECRET`
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `EC2_HOST`
- `EC2_USERNAME`
- `EC2_SSH_KEY`

Sensitive values should never be hardcoded into workflow files or committed to Git.

---

## 12. Branch Protection

The `main` branch is protected.

Changes must go through a Pull Request instead of being pushed directly.

Required checks include:

- `test (3.11)`
- `test (3.12)`
- `test (3.13)`
- `build`

This provides a controlled path:

Feature Branch
      ↓
Pull Request
      ↓
Automated Checks
      ↓
Merge
      ↓
main
      ↓
Deployment

---

## 13. Deployment Verification

The complete pipeline was successfully tested.

Final workflow result:

- `test (3.11)` ✅
- `test (3.12)` ✅
- `test (3.13)` ✅
- `build` ✅
- `deploy` ✅

The EC2 server successfully:

- Connected through SSH.
- Pulled the Docker image.
- Replaced the old container.
- Started the new container.

The Flask application was verified through the EC2 public endpoint.

Expected response:

`Hello from CI/CD! Version 1.0`

---

## 14. Troubleshooting Experience

During deployment, the first CD attempt failed with:

`dial tcp 13.211.207.128:22: i/o timeout`

The problem was not Docker or the GitHub Actions workflow.

The EC2 Security Group allowed SSH only from the developer's local IP:

`103.161.54.26/32`

GitHub Actions uses a GitHub-hosted runner with a different source IP.

For the learning environment, the SSH rule was temporarily changed to:

`0.0.0.0/0`

After updating the Security Group, the deployment succeeded.

This demonstrated an important troubleshooting principle:

Deployment failure
      ↓
Check deployment logs
      ↓
Identify failing layer
      ↓
SSH connection timeout
      ↓
Check EC2 Security Group
      ↓
Port 22 access problem
      ↓
Correct inbound rule
      ↓
Deployment succeeds

Note: Allowing `0.0.0.0/0` on SSH exposes port 22 to the internet. This was used as a temporary learning configuration and should be tightened for a production environment.

---

## 15. Final Mental Model

CI answers:

"Does the code work and can we build it?"

CD answers:

"Can we automatically deliver the verified version to the server?"

The complete pipeline is:

Code
  ↓
Git
  ↓
GitHub
  ↓
Pull Request
  ↓
CI
  ↓
Tests
  ↓
Docker Build
  ↓
Docker Hub
  ↓
Merge to main
  ↓
CD
  ↓
SSH
  ↓
EC2
  ↓
Docker Pull
  ↓
New Container
  ↓
Application Live

---

## 16. Key Concepts Learned

- Continuous Integration
- Continuous Deployment
- GitHub Actions workflows
- Jobs and steps
- GitHub Actions runners
- Matrix strategy
- Job dependencies with `needs`
- Conditional execution with `if`
- Pull Request CI
- Branch protection
- GitHub Actions Secrets
- Docker image building
- Docker Hub image registry
- SSH-based deployment
- AWS EC2 deployment
- Security Groups
- Automated container replacement
- Remote `main` vs local `main`
- CI/CD troubleshooting

---

## 17. Project Status

CI/CD learning project: COMPLETE ✅

The pipeline has been implemented and successfully verified end-to-end.

Final flow:

Feature Branch
      ↓
Pull Request
      ↓
CI Tests
      ↓
Docker Build
      ↓
Docker Hub
      ↓
Merge to main
      ↓
Automatic CD
      ↓
AWS EC2
      ↓
Docker Container
      ↓
Flask Application Live

