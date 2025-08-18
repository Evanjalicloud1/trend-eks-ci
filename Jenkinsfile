pipeline {
  agent any
  environment {
    AWS_REGION        = 'ap-south-1'
    EKS_CLUSTER_NAME  = 'trend-eks'
    DOCKERHUB_REPO    = 'dockerhub_username/trend'
    IMAGE_TAG         = "${env.BUILD_NUMBER}"
  }
  options { timestamps() }
  triggers { githubPush() }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build React') { steps { sh 'npm ci --no-audit --progress=false && npm run build' } }
    stage('Docker Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh '''
          echo "" | docker login -u "" --password-stdin
          docker build -t : -t :latest .
          docker push :
          docker push :latest
          '''
        }
      }
    }
    stage('Deploy to EKS') {
      steps {
        sh '''
        aws eks update-kubeconfig --name  --region 
        kubectl apply -f k8s/deployment.yaml
        kubectl apply -f k8s/service.yaml
        kubectl set image deployment/trend-web web=: --record || true
        kubectl rollout status deployment/trend-web --timeout=120s
        '''
      }
    }
  }
}
