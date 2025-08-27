pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "evanjali1468/trend-app"   // 🔹 Replace with your DockerHub repo
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-ssh', url: 'git@github.com:Evanjalicloud1/trend-eks-ci.git', branch: 'main'
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
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {  // 🔹 Use your Jenkins credential ID
                        def app = docker.build("${DOCKERHUB_REPO}:latest")
                        app.push()
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                echo "🔹 Deploying to EKS..."
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                '''
            }
        }

        stage('Get LoadBalancer URL') {
            steps {
                sh '''
                echo "🔹 Waiting for LoadBalancer external IP..."
                kubectl get svc trend-service -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" --watch-only &
                sleep 30
                kubectl get svc trend-service -o wide
                '''
            }
        }
    }
}
