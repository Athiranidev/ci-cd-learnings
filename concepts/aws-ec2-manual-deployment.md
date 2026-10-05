# CD Practical — Docker → Docker Hub → AWS EC2

## Goal

Deploy the Dockerized Flask application to an AWS EC2 server.

Final target:

GitHub
  ↓
CI
  ↓
Docker Image
  ↓
Docker Hub
  ↓
AWS EC2
  ↓
Docker Container
  ↓
Flask Application
  ↓
Internet

---

# 1. Flask Application

Created a simple Flask application for practicing real deployment.

`app.py`:

    from flask import Flask

    app = Flask(__name__)

    @app.route("/")
    def home():
        return "Hello from CI/CD! Version 1.0"

    if __name__ == "__main__":
        app.run(host="0.0.0.0", port=5000)

The application listens on:

    0.0.0.0:5000

---

# 2. Dockerfile

Dockerfile:

    FROM python:3.12-slim

    WORKDIR /app

    COPY requirements.txt .
    RUN pip install -r requirements.txt

    COPY app.py .

    EXPOSE 5000

    CMD ["python3", "app.py"]

Important:

- `FROM` → base image
- `WORKDIR /app` → working directory inside the image/container
- `COPY` → copies files from build context into the image
- `RUN` → installs Python dependencies during image build
- `EXPOSE 5000` → documents the application's container port
- `CMD` → default command executed when the container starts

---

# 3. Build Docker Image

Built the Flask application image locally:

    docker build -t ci-cd-flask-app:v1 .

This created the Docker image:

    ci-cd-flask-app:v1

---

# 4. Run Container Locally

Ran the application locally:

    docker run -d \
      --name ci-cd-flask-app \
      -p 5000:5000 \
      ci-cd-flask-app:v1

Tested:

    curl http://localhost:5000

Result:

    Hello from CI/CD! Version 1.0

This confirmed the Dockerized Flask application worked locally.

---

# 5. Push Image to Docker Hub

Tagged the image for Docker Hub:

    docker tag ci-cd-flask-app:v1 athiranidev/ci-python-app:cd-v1

Pushed it:

    docker push athiranidev/ci-python-app:cd-v1

Docker Hub image:

    athiranidev/ci-python-app:cd-v1

Image digest:

    sha256:6cc083341586...

The Docker image is now stored in Docker Hub.

---

# 6. Create AWS EC2 Server

Created a new EC2 instance for the CD deployment.

Configuration:

- Region: Sydney
- Region code: `ap-southeast-2`
- Instance name: `ci-cd-demo-server`
- OS: Ubuntu Server
- Architecture: 64-bit x86
- Instance type: `t3.micro`
- Storage: 8 GiB gp3
- Public IPv4: Enabled

Instance:

    ci-cd-demo-server

Instance ID:

    i-032d1c52d2e2dacb3

The instance reached:

    Running
    3/3 status checks passed

---

# 7. SSH Key Pair

Created an EC2 key pair:

    ci-cd-demo-key

Downloaded:

    ci-cd-demo-key.pem

The `.pem` file is the private SSH key used to authenticate to the EC2 server.

On the local Ubuntu machine:

    cd ~/Downloads

    chmod 400 ci-cd-demo-key.pem

`chmod 400` restricts the private key so only the owner can read it.

The private key must NOT be committed to GitHub.

---

# 8. EC2 Security Group

Configured inbound rules for the EC2 server.

Current relevant rules:

- SSH → TCP 22 → My IP
- HTTP → TCP 80 → Internet
- HTTPS → TCP 443 → Internet

SSH initially stopped working because the local public IP changed.

Old IP:

    103.181.41.19

Current IP:

    103.161.54.26

Updated the SSH security-group rule to the current IP.

This demonstrated an important real-world point:

    Security Group
        ↓
    Controls inbound network access
        ↓
    SSH port 22

If the allowed source IP changes, SSH can time out.

---

# 9. Connect to EC2 Using SSH

Connected from the local Ubuntu machine:

    ssh -i "ci-cd-demo-key.pem" \
    ubuntu@ec2-13-211-207-128.ap-southeast-2.compute.amazonaws.com

Successful EC2 prompt:

    ubuntu@ip-172-31-44-234:~$

This confirmed that we were working inside the AWS EC2 server.

---

# 10. Update EC2 Packages

Inside EC2:

    sudo apt update

The package index was successfully updated.

---

# 11. Install Docker on EC2

Installed Docker:

    sudo apt install docker.io -y

Verified:

    docker --version

Result:

    Docker version 29.1.3

---

# 12. Verify Docker on EC2

Ran:

    sudo docker run hello-world

Docker successfully:

1. Contacted the Docker daemon
2. Pulled the `hello-world` image from Docker Hub
3. Created a container
4. Ran the container
5. Displayed the output

This confirmed Docker was working correctly on EC2.

---

# 13. Pull Our Application Image to EC2

Pulled our actual application image:

    sudo docker pull athiranidev/ci-python-app:cd-v1

Result:

    Status: Downloaded newer image for
    athiranidev/ci-python-app:cd-v1

Digest:

    sha256:6cc083341586...

This means the same application image stored in Docker Hub was downloaded onto the EC2 server.

---

# 14. Run Flask Container on EC2

Started the application:

    sudo docker run -d \
      --name ci-cd-flask-app \
      -p 5000:5000 \
      athiranidev/ci-python-app:cd-v1

Verified:

    sudo docker ps

Result showed:

    IMAGE:
    athiranidev/ci-python-app:cd-v1

    STATUS:
    Up

    PORTS:
    0.0.0.0:5000->5000/tcp

    NAME:
    ci-cd-flask-app

Meaning:

    EC2 host port 5000
            ↓
    Docker container port 5000
            ↓
    Flask application

---

# 15. Test Flask Inside EC2

Ran:

    curl http://localhost:5000

Result:

    Hello from CI/CD! Version 1.0

This proves the application is running correctly inside the EC2 Docker container.

---

# Current Architecture

At the end of today's work:

    GitHub
       ↓
    CI
       ↓
    Docker Image
       ↓
    Docker Hub
       ↓
    AWS EC2
       ↓
    Docker Container
       ↓
    Flask Application
       ↓
    localhost:5000

---

# Completed Today

- Flask application                    ✅
- Dockerfile                           ✅
- Docker image                         ✅
- Local Docker container               ✅
- Docker Hub repository/image          ✅
- AWS EC2 instance                     ✅
- SSH access                           ✅
- EC2 Docker installation              ✅
- Docker verification                  ✅
- Application image pulled to EC2     ✅
- Application container running       ✅
- Flask application tested on EC2     ✅

---

# Remaining Work

## 1. Public access

Allow TCP port `5000` in the EC2 security group.

Then test from the local browser:

    http://13.211.207.128:5000

Expected:

    Hello from CI/CD! Version 1.0

---

## 2. Automated CD

Currently deployment is manual:

    Docker Hub
        ↓
    EC2
        ↓
    docker pull
        ↓
    docker run

We will automate this using GitHub Actions:

    git push
        ↓
    CI
        ↓
    Build Docker image
        ↓
    Push image to Docker Hub
        ↓
    Connect to EC2
        ↓
    Pull new image
        ↓
    Replace old container
        ↓
    New version LIVE

---

## 3. Version Update Test

Change:

    Version 1.0

to:

    Version 2.0

Then push the change and verify that the CD pipeline automatically deploys Version 2.0 to EC2.

---

## Final Goal

Complete the full real-world flow:

    Developer
       ↓
    GitHub
       ↓
    CI
       ↓
    Docker Build
       ↓
    Docker Hub
       ↓
    CD
       ↓
    AWS EC2
       ↓
    Docker Container
       ↓
    Live Application