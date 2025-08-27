pipeline {
    agent any

    environment {
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
                    docker.withRegistry('', 'dockerhub-credentials') {
                        def app = docker.build("${DOCKERHUB_REPO}:${env.BUILD_NUMBER}")
                        app.push()
                        app.push("latest")
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-eks-creds', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        # Configure AWS CLI dynamically
                        mkdir -p ~/.aws
                        cat > ~/.aws/credentials <<EOL
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
EOL

                        # Deploy to EKS
                        aws eks update-kubeconfig --region ap-south-1 --name trend-eks
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }
}
