pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_REPO = "evanjali1468/trend-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-ssh',
                    url: 'git@github.com:Evanjalicloud1/trend-eks-ci.git'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm install'
                sh 'npm run build'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('', dockerhub-credentials) {
                        def app = docker.build("${DOCKERHUB_REPO}:${env.BUILD_NUMBER}")
                        app.push()
                        app.push("latest")
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                aws eks update-kubeconfig --region us-east-1 --name trend-eks
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }
}
