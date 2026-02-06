pipeline {
  agent any
  environment {
    DOCKER_REGISTRY = credentials('docker-registry-url') // optional if using login creds only
    DOCKER_CRED_ID = 'dockerhub-creds' // set this credential ID in Jenkins
    IMAGE_NAME = "krsaikrishna/devops-demo"
    KUBECONFIG_CRED = 'kubeconfig-cred' // Jenkins credential (Secret file) containing kubeconfig
    TAG = "${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Install & Test') {
      steps {
        sh 'npm ci || npm install' 
        sh 'npm test || true'
      }
    }
    stage('Build Docker Image') {
      steps {
        script {
          sh "docker build -t ${IMAGE_NAME}:${TAG} ."
        }
      }
    }
    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${IMAGE_NAME}:${TAG}
            docker logout
          '''
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        // write kubeconfig to file and use kubectl
        withCredentials([file(credentialsId: "${KUBECONFIG_CRED}", variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG=${KUBECONFIG_FILE}
            # update image in the k8s deployment (creates deployment if not present)
            kubectl apply -f k8s/deployment.yaml
            kubectl apply -f k8s/service.yaml
            kubectl set image deployment/devops-demo devops-demo=${IMAGE_NAME}:${TAG} --record || true
            kubectl rollout status deployment/devops-demo --timeout=120s
          '''
        }
      }
    }
  }
  post {
    success {
      echo "Pipeline finished successfully. Image: ${IMAGE_NAME}:${TAG}"
    }
    failure {
      echo "Pipeline failed."
    }
  }
}
