Trend App – CI/CD on AWS EKS with Jenkins, Docker, and Grafana

This project demonstrates a complete CI/CD pipeline for deploying a React application on AWS EKS (Elastic Kubernetes Service) using Jenkins, Docker, and Kubernetes, with monitoring via Grafana + Prometheus.
1)Architecture Workflow

App: React (Create React App), built to static assets and served by nginx in a container.

Registry: Docker Hub → evanjali1468/trend-app

Cluster: AWS EKS → trend-eks (region ap-south-1)

Kubernetes:

Namespace: trend-app

Deployment: trend-app (nginx serving build)

Service: trend-app (type LoadBalancer, port 80, client port 3000)

CI/CD: Jenkins pipeline (build → push → deploy)

Monitoring (optional): kube-prometheus-stack (Prometheus + Grafana)

2) Prerequisites

AWS account & IAM user with EKS permissions

EKS cluster created (name: trend-eks, region: ap-south-1)

On Jenkins server (or admin host):

Docker, Git, Node.js 18+, AWS CLI v2, kubectl, Helm

Network egress to Docker Hub & GitHub

Credentials

Docker Hub credentials in Jenkins: dockerhub-credentials

GitHub SSH key in Jenkins: github-ssh

AWS creds in Jenkins: aws-eks-creds (Access key ID/Secret key)

3) Repo Structure

   .
├─ Dockerfile
├─ Jenkinsfile.old
├─ nginx.conf
├─ k8s/
│  ├─ deployment.yaml
│  └─ service.yaml
├─ src/  public/  package.json  package-lock.json
└─ README.md

4) Local Development & Test

   # install deps
npm ci || npm install

# dev (optional)
npm start

# production build
npm run build

# docker build & run (serves build at nginx:80 → host:3000)
docker build -t trend-app .
docker run -d -p 3000:80 trend-app
# open: http://<EC2-Public-IP>:3000  (allow SG inbound TCP/3000)

5) Container Image (Docker Hub)

The Jenkins pipeline builds and pushes:

docker.io/evanjali1468/trend-app:<build-number>

docker.io/evanjali1468/trend-app:latest

6) Kubernetes Manifests
k8s/deployment.yaml
k8s/service.yaml

Apply:

kubectl create namespace trend-app --dry-run=client -o yaml | kubectl apply -f -
kubectl -n trend-app apply -f k8s/deployment.yaml
kubectl -n trend-app apply -f k8s/service.yaml
kubectl -n trend-app rollout status deploy/trend-app --timeout=240s

Get URL:
H=$(kubectl -n trend-app get svc trend-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "APP URL: http://$H:3000"

7) EKS Cluster

   # configure kubeconfig
aws eks --region ap-south-1 update-kubeconfig --name trend-eks

# sanity
kubectl get nodes -o wide

8) Jenkins CI/CD

Pipeline job → use Jenkinsfile.old.

Key environment in Jenkinsfile:

DOCKERHUB_REPO = 'evanjali1468/trend-app'

AWS_REGION = 'ap-south-1'

EKS_CLUSTER = 'trend-eks'

Credentials used

github-ssh (SSH private key for repo access)

dockerhub-credentials (DockerHub username/password)

aws-eks-creds (AWS access key/secret key)
Stages (what it does)

Checkout – pulls main via SSH.

Build React – npm ci || npm install and npm run build.

Docker Build & Push – builds and pushes tags to Docker Hub.

Deploy to EKS – updates kubeconfig, applies manifests, waits for rollout, prints LB URL.

GitHub Webhook

Add a webhook in your repo:
Settings → Webhooks → Add webhook

Payload URL: http://<jenkins-host>:8080/github-webhook/

Content type: application/json

Events: “Just push events”

Active

Jenkins job → configure → Build Triggers: “GitHub hook trigger for GITScm polling”.

9) Monitoring

    Install with Helm
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install mon prometheus-community/kube-prometheus-stack -n monitoring

Access Grafana
Quick local port-forward:

kubectl -n monitoring port-forward svc/mon-grafana 3001:80
# open http://3.110.197.67:3001  (default login: admin / prom-operator)

10) Outputs
App URL (LB DNS):
http://a294148cbcbdd46e8af57affb9d1a816-1663830740.ap-south-1.elb.amazonaws.com  
LoadBalancer ARN:
arn:aws:elasticloadbalancing:ap-south-1:767828768641:loadbalancer/a294148cbcbdd46e8af57affb9d1a816

GitHub repo link:
https://github.com/Evanjalicloud1/trend-eks-ci


