pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'evanjali1468'
        IMAGE_NAME = 'trend-app'
    }

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
                    image 'node:18'   // ✅ Run build in Node.js container
                    args '-v $WORKSPACE:/app -w /app'
                }
            }
            steps {
                sh '''
                echo "Installing dependencies..."
                npm install
                echo "Building React app..."
                npm run build
                '''
            }
        }

        stage('Docker Build & Push') {
            steps {
                withDockerRegistry([ credentialsId: 'docker-hub', url: '' ]) {
                    sh '''
                    echo "Building Docker image..."
                    docker build -t $DOCKER_HUB_USER/$IMAGE_NAME:latest .
                    echo "Pushing Docker image to DockerHub..."
                    docker push $DOCKER_HUB_USER/$IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                echo "Deploying to EKS..."
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }
}
