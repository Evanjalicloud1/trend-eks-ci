pipeline {
    agent any

    environment {
        DOCKERHUB_REPO = "evanjali1468/trend-app"
        AWS_REGION = "ap-south-1"
        EKS_CLUSTER = "trend-eks"
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
                withCredentials([usernamePassword(credentialsId: 'aws-eks-creds', 
                                                 usernameVariable: 'AWS_ACCESS_KEY_ID', 
                                                 passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh '''
                        # Configure AWS CLI dynamically
                        mkdir -p ~/.aws
                        cat > ~/.aws/credentials <<EOL
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
EOL
                        aws configure set region $AWS_REGION

                        # Update kubeconfig
                        aws eks update-kubeconfig --region $AWS_REGION --name $EKS_CLUSTER

                        # Deploy manifests
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml

                        # Print LoadBalancer URL dynamically
                        echo "EKS LoadBalancer URL:"
                        kubectl get svc $(kubectl get svc -o jsonpath='{.items[0].metadata.name}') -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}
