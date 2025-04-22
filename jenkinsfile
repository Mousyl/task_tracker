pipeline {
    agent any

    environment {
        REMOTE_USER = 'ubuntu'
        REMOTE_HOST = credentials('ec2-connection')
        REPO = 'git@github.com:Mousyl/task_tracker.git'
        PROJECT_DIR = 'task_tracker'
    }

    stages {
        stage('Clone repo to EC2') {
            steps {
                sshagent(credentials: ['ec2-key', 'github-ssh']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_HOST '
                        rm -rf $PROJECT_DIR || true &&
                        git clone -b main $REPO $PROJECT_DIR &&
                        cd $PROJECT_DIR &&
                        rm -rf infra &&
                        
                        docker-compose down || true &&
                        docker-compose up --build -d
                        '
                    """
                }
            }
        }


        stage('Health check') {
            steps {
                sh """
                echo 'Waiting for app to become alive...'
                sleep 10
                curl -f http://$REMOTE_HOST || echo 'App is not responding'
                """
            }
        }
    }

    post {
        success {
            echo 'Deploy completed successfuly! Check the app: http://$REMOTE_HOST'
        }
        failure {
            echo 'Error during deploy'
        }
    }
}