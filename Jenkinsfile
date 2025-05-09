pipeline {
    agent any
    
    environment {
        AWS_REGION = 'eu-north-1'
        CLUSTER_NAME = 'task-tracker-cluster'
        DEPLOYMENT_NAME = 'task-tracker'
        NAMESPACE = 'default'
        DOCKER_IMAGE = 'mousyl/task-tracker'
        AWS_CREDS = credentials('aws_creds')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Generate docker image') {
            steps {
                script {
                    def timestamp = new Date().format("yyyyMMdd-HHmmss", TimeZone.getTimeZone('UTC'))
                    env.IMAGE_TAG = "build-${timestamp}"
                    env.DOCKER_IMAGE_FULL = "${env.DOCKER_IMAGE}:${env.IMAGE_TAG}"

                    echo "Image tag: ${env.IMAGE_TAG}"
                    echo "Docker full image: ${env.DOCKER_IMAGE_FULL}"
                }
            }
        }
        
        stage('Build and Validate') {
            parallel {
                stage('Image Build') {
                    steps {
                        script {
                            sh """
                            docker build -t ${env.DOCKER_IMAGE_FULL} .
                            """
                        }
                    }
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
        
        stage('Push image to DockerHub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub_creds', 
                        usernameVariable: 'DOCKERHUB_USER', 
                        passwordVariable: 'DOCKERHUB_PASS')
                ]) {
                    script {
                        sh """
                        echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                        docker push ${env.DOCKER_IMAGE_FULL}
                        """
                    }
                }
            }
        }
 
        stage('Deploy') {
            steps {
                dir('infra') {
                    script {
                        withCredentials([file(credentialsId: 'tfvars', variable: 'TFVARS_FILE')]) {
                            try {
                                sh """
                                if [ ! -f terraform.tfvars ]; then
                                    cp ${TFVARS_FILE} terraform.tfvars
                                else
                                    echo "terraform.tfvars file already exists" 
                                fi

                                terraform init -input=false
                                terraform apply -auto-approve -var-file=terraform.tfvars -var='app_image=${env.DOCKER_IMAGE_FULL}'
                                """
                            }
                            catch(err) {
                                echo "Terraform failed: ${err.getMessage()}"
                                error "Stopping pipeline due to terraform error."
                            }
                        }
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
                script {
                    try {
                        sh """
                        aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
                        kubectl rollout undo deployment $DEPLOYMENT_NAME --namespace $NAMESPACE || echo 'Rollback failed.'
                        """
                    } catch (Exception e) {
                        echo "Rollback failed: ${e.getMessage()}"
                    }
                }
            }
        }
        
        success {
            echo "Deployment completed successfully"
            sh "docker rmi ${env.DOCKER_IMAGE_FULL} || true"
        }
        
        always {
            sh """
            docker logout || true
            rm -f infra/terraform.tfvars || true
            """
        }
    }
}