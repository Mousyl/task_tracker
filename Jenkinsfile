pipeline {
    agent any

    environment {
        REMOTE_USER = 'ubuntu'
        REPO = 'git@github.com:Mousyl/task_tracker.git'
        PROJECT_DIR = 'task_tracker'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-ssh',
                    url: "${REPO}"
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-key']) {
                    withCredentials([
                        string(credentialsId: 'ec2-connection', variable: 'REMOTE_HOST'),
                        usernamePassword(credentialsId: 'db-credentials', usernameVariable: 'DB_USER', passwordVariable: 'DB_PASSWORD'),
                        string(credentialsId: 'db-name', variable: 'DB_NAME')
                    ]) {
                        // First, ensure remote directory exists and is clean
                        sh '''
                            ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                                mkdir -p ${PROJECT_DIR}
                                cd ${PROJECT_DIR}
                                rm -rf * .[^.]*
                            "
                        '''
                        
                        sh '''
                            rsync -avz --exclude '.git' --exclude 'infra' ./ ${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/
                        '''

                        sh '''
                            ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                                cd ${PROJECT_DIR}
                                echo 'DB_USER=${DB_USER}' > .env
                                echo 'DB_PASSWORD=${DB_PASSWORD}' >> .env
                                echo 'DB_NAME=${DB_NAME}' >> .env
                                chmod 600 .env
                                
                                if ! systemctl is-active --quiet docker; then
                                    sudo systemctl start docker
                                    sleep 5
                                fi

                                docker-compose down || true
                                docker-compose up --build -d
                            "
                        '''
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                withCredentials([string(credentialsId: 'ec2-connection', variable: 'REMOTE_HOST')]) {
                    sh '''
                        sleep 30
                        
                        if curl -f http://${REMOTE_HOST}; then
                            echo "Application is running!"
                        else
                            echo "Application is not responding"
                            exit 1
                        fi
                    '''
                }
            }
        }
    }

    post {
        success {
            withCredentials([string(credentialsId: 'ec2-connection', variable: 'REMOTE_HOST')]) {
                echo "Deployment successful! Check the app: http://${REMOTE_HOST}"
            }
        }
        failure {
            echo "Deployment failed. Check the logs below:"
            sshagent(credentials: ['ec2-key']) {
                withCredentials([string(credentialsId: 'ec2-connection', variable: 'REMOTE_HOST')]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                            cd ${PROJECT_DIR}
                            docker-compose logs
                        "
                    '''
                }
            }
        }
    }
}