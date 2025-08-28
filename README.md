Trend App – CI/CD on AWS EKS with Jenkins, Docker, and Grafana

This project demonstrates a complete CI/CD pipeline for deploying a React application on AWS EKS (Elastic Kubernetes Service) using Jenkins, Docker, and Kubernetes, with monitoring via Grafana + Prometheus.
Architecture Workflow

Developer commits code → GitHub repo.

Jenkins pipeline pulls code → builds React app → creates Docker image → pushes to Docker Hub.

Jenkins deploys to AWS EKS cluster via kubectl.

Kubernetes Deployment + Service exposes the app via AWS LoadBalancer.

Grafana + Prometheus monitor the cluster and app.

Prerequisites

AWS Account with IAM permissions for EKS, EC2, and ELB.

EC2 Instance (Ubuntu) for Jenkins server.

Installed on Jenkins server:

Jenkins + required plugins (Git, Docker, Kubernetes, Pipeline).

Docker & Docker Hub credentials.

AWS CLI + kubectl + eksctl + Helm.

GitHub SSH Key added to Jenkins credentials (github-ssh).

Setup Instructions
1️.Jenkins Setup

Install Jenkins on EC2 (sudo apt install jenkins).

Install required plugins: Git, Pipeline, Docker Pipeline, Kubernetes CLI, SSH Agent.

Add credentials in Jenkins:

github-ssh → GitHub SSH key.

dockerhub-credentials → Docker Hub username/password.

aws-eks-creds → AWS Access Key ID / Secret.

2.Docker Build & Push

Dockerfile used:

FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html

