pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'git@github.com:Evanjalicloud1/trend-eks-ci.git',
                    credentialsId: 'github-ssh'
            }
        }

        stage('Build React') {
            agent {
                docker {
                    image 'node:18'   // Use official Node.js 18 Docker image
                }
            }
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        def customImage = docker.build("evanjali1468/trend-app:latest")
                        customImage.push()
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
    }
}
