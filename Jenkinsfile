pipeline {
    agent any

    environment {
        REMOTE_USER = 'ubuntu'
        REMOTE_HOST = credentials('ec2-connection')
        REPO = 'git@github.com:Mousyl/task_tracker.git'
        PROJECT_DIR = 'task_tracker'
    }

    stages {
        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: ['ec2-key', 'github-ssh']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST '
                        if ! systemctl is-active --quiet docker; then
                            sudo systemctl start docker
                            sleep 5
                        fi

                        rm -rf $PROJECT_DIR

                        git clone -b main $REPO $PROJECT_DIR
                        cd $PROJECT_DIR
                        rm -rf infra

                        docker-compose down
                        docker-compose up --build -d
                    '
                    """
                }
            }
        }

        stage('Check if app is running') {
            steps {
                sh """
                sleep 30
                
                if curl -f http://$REMOTE_HOST; then
                    echo "Application is running!"
                else
                    echo "Application is not responding"
                    exit 1
                fi
                """
            }
        }
    }

    post {
        success {
            echo "Deployment successful! Check the app: http://$REMOTE_HOST"
        }
        failure {
            echo "Deployment failed. Check the logs below:"
            sshagent(credentials: ['ec2-key']) {
                sh """
                ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST '
                    cd $PROJECT_DIR
                    docker-compose logs
                '
                """
            }
        }
    }
}