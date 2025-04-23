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
                        file(credentialsId: 'env-file', variable: 'ENV_FILE')
                    ]) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                            mkdir -p ${PROJECT_DIR}
                            cd ${PROJECT_DIR}
                            rm -rf * .[^.]*
                        "

                        scp -o StrictHostKeyChecking=no \$ENV_FILE ${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/.env
                        
                        rsync -avz --exclude '.git' --exclude 'infra' ./ ${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/

                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST}"
                            cd ${PROJECT_DIR}
                            chmod 600 .env
                            if [ -f .env]; then
                                echo '.env file created'
                            else
                                echo '.env file not created'
                                ls -la
                                exit 1
                            fi
                        
                        docker-compose down -v || true
                        docker system prune -f
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
                            echo 'Container Status:'
                            docker ps -a
                            docker logs task_tracker_db_1 || true
                            docker logs task_tracker-app-1 || true
                        "
                    '''
                }
            }
        }
        always {
            cleanWs()
        }
    }
}