pipeline {
    agent any
    
    environment {
        AWS_REGION = 'eu-north-1'
        CLUSTER_NAME = 'task-tracker-cluster'
        DEPLOYMENT_NAME = 'task-tracker'
        NAMESPACE = 'default'
        DOCKER_IMAGE = 'mousyl/task-tracker'
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
                script {
                    try {
                        withCredentials([
                            [$class: 'AmazonWebServicesCredentialsBinding', 
                             credentialsId: 'aws_creds'],
                            [file(credentialsId: 'tfvars', variable: 'TFVARS_FILE')],
                            [usernamePassword(
                                credentialsId: 'db_creds',
                                usernameVariable: 'DB_USER',
                                passwordVariable: 'DB_PASSWORD'
                            )]
                        ]) {
                            dir('infra') {
                                sh """
                                cp ${TFVARS_FILE} terraform.tfvars.tmp
                                sed -i "s/db_password = .*/db_password = \\"${DB_PASSWORD}\\"/" terraform.tfvars.tmp
                                sed -i "s/db_user = .*/db_user = \\"${DB_USER}\\"/" terraform.tfvars.tmp
                                
                                terraform init
                                terraform apply -auto-approve -var-file=terraform.tfvars.tmp -var='app_image=${env.DOCKER_IMAGE_FULL}'
                                
                                rm terraform.tfvars.tmp
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
            sh "docker logout || true"
        }
    }
}