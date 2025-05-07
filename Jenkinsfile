pipeline {
    agent any
    
    environment {
        AWS_REGION = 'eu-north-1'
        CLUSTER_NAME = 'task-tracker-cluster'
        DEPLOYMENT_NAME = 'task-tracker'
        NAMESPACE = 'default'
        DOCKER_IMAGE = 'mousyl/task-tracker'
        IMAGE_TAG = ''
        GIT_SHA = ''
        DOCKER_IMAGE_FULL = ''
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm

                script {
                    dir('.') {
                        def gitSha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        env.GIT_SHA = gitSha
                        env.IMAGE_TAG = "build-${env.GIT_SHA}"
                        env.DOCKER_IMAGE_FULL = "${env.DOCKER_IMAGE}:${env.IMAGE_TAG}"

                        echo "Image tag: ${env.IMAGE_TAG}"
                        echo "Docker full image: ${env.DOCKER_IMAGE_FULL}"
                    }
                }
            }
        }
        
        stage('Image Build') {
            steps {
                sh """
                docker build -t ${env.DOCKER_IMAGE_FULL} .
                """
            }
        }
        
        stage('Push image to DockerHub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub_creds', 
                        usernameVariable: 'DOCKERHUB_USER', 
                        passwordVariable: 'DOCKERHUB_PASS')
                ]) {
                    sh """
                    echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                    docker push ${DOCKER_IMAGE_FULL}
                    """
                }
            }
        }
        
        stage('Terraform config validation') {
            steps {
                dir('infra') {
                    sh """
                    terraform init -backend=false
                    terraform validate
                    """
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    try {
                        withCredentials([[
                            $class: 'AmazonWebServicesCredentialsBinding', 
                            credentialsId: 'aws_creds'
                        ]]) {
                            dir('infra') {
                                sh """
                                terraform init
                                terraform apply -auto-approve -var='app_image=${DOCKER_IMAGE_FULL}'
                                """
                            }
                        }
                    }
                    catch(err) {
                        echo "Terraform failed: ${err.getMessage()}"
                        error "Stopping pipeline due to terraform error."
                    }
                }
            }
        }
    }
    
    post {
        failure {
            echo "Pipeline failed! Attempting rollback..."

            withCredentials([[
                $class: 'AmazonWebServicesCredentialsBinding', 
                credentialsId: 'aws_creds'
            ]]) {
                sh """
                aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
                kubectl rollout undo deployment $DEPLOYMENT_NAME --namespace $NAMESPACE || echo 'Rollback failed.'
                """
            }
        }
        
        success {
            echo "Deployment completed successfully"
        }
    }
}