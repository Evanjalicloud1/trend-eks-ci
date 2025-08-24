 pipeline {
  agent any
  environment {
    AWS_REGION        = 'ap-south-1'
    EKS_CLUSTER_NAME  = 'trend-eks'
    DOCKERHUB_REPO    = 'evanjali1468/trend'
    IMAGE_TAG         = "${env.BUILD_NUMBER}"
  }
  options { timestamps() }
  triggers { githubPush() }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build React') {
      steps {
        sh 'npm ci --no-audit --progress=false && npm run build'
      }
    }

    stage('Docker Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh '''
          echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
          docker build -t $DOCKERHUB_REPO:$IMAGE_TAG -t $DOCKERHUB_REPO:latest .
          docker push $DOCKERHUB_REPO:$IMAGE_TAG
          docker push $DOCKERHUB_REPO:latest
          '''
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        sh '''
        aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION
        kubectl apply -f k8s/deployment.yaml
        kubectl apply -f k8s/service.yaml
        kubectl set image deployment/trend-web web=$DOCKERHUB_REPO:$IMAGE_TAG --record || true
        kubectl rollout status deployment/trend-web --timeout=120s
        '''
      }
    }
  }
}
