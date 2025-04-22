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
                        string(credentialsId: 'db-name', variable: 'DB_NAME'),
                        string(credentialsId: 'secret-key', variable: 'SECRET_KEY'),
                        string(credentialsId: 'algorithm', variable: 'ALGORITHM'),
                        string(credentialsId: 'token-expire', variable: 'TOKEN_EXPIRE')
                    ]) {

                        sh '''
                            ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                                mkdir -p ${PROJECT_DIR}
                                cd ${PROJECT_DIR}
                                
                                if [ -f .env ]; then
                                    cp .env .env.backup
                                fi
                                
                                find . -mindepth 1 -maxdepth 1 ! -name '.env.backup' -exec rm -rf {} +
                            "
                        '''
                        
                        sh '''
                            rsync -avz --exclude '.git' --exclude 'infra' ./ ${REMOTE_USER}@${REMOTE_HOST}:${PROJECT_DIR}/
                        '''

                        sh '''
                            ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "
                                cd ${PROJECT_DIR}
                                
                                cat > .env << 'EOL'
                                SECRET_KEY=${SECRET_KEY}
                                ALGORITHM=${ALGORITHM}
                                ACCESS_TOKEN_EXPIRE_MINUTES=${TOKEN_EXPIRE}
                                DB_NAME=${DB_NAME}
                                DB_USER=${DB_USER}
                                DB_PASSWORD=${DB_PASSWORD}
                                DB_HOST=db
                                DB_PORT=5432
                                DOCKER_CONTAINER=true
                                DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
                                EOL
                                
                                chmod 600 .env
                                
                                ${DOCKER_COMPOSE} down -v || true
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
                echo " Deployment successful! 🌐 Application URL: http://${REMOTE_HOST}"
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