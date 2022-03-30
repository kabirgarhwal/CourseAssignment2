pipeline {
    agent {
      label 'worker'
    }
    options {
            buildDiscarder(logRotator(numToKeepStr: '10'))
            disableConcurrentBuilds()
            timeout(time: 1, unit: 'HOURS')
    }
    environment {
            AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        stage('Git Checkout') {
          steps {
            checkout scm
          }
        }
        stage('Build Docker Image') {
            steps {
                sh "eval \$(aws ecr get-login --no-include-email --region us-east-1) && sleep 2"
                sh "cd assignment && docker build . -t 463178143075.dkr.ecr.us-east-1.amazonaws.com/ecr-kabir:\${BUILD_NUMBER}" 
                sh "docker push 463178143075.dkr.ecr.us-east-1.amazonaws.com/ecr-kabir:\${BUILD_NUMBER}"
            }
        }
        stage('Deploy in App Instance') {
            steps {

                script {
                    sh'''
                    ssh -i test.pem ubuntu@10.0.3.154		
			  docker run -it --name=assignment -d -p 8080:8080 alpine:latest
				'''
                }
            }
        }
    }

}
