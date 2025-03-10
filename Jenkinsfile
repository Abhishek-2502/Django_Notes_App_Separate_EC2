pipeline {
    agent any

    environment {
        IMAGE_NAME = "django-note-app"
        DOCKER_HUB_REPO = "abhi25022004/django-note-app"
        GIT_REPO = "https://github.com/Abhishek-2502/Django_Notes_App_Separate_EC2.git"
        DEPLOY_DIR = "/home/ubuntu/Django_Notes_App_Separate_EC2"
    }

    stages {
        stage("Clone Latest Code in Jenkins") {
            steps {
                script {
                    if (fileExists("workspace")) {
                        echo "Fetching latest changes..."
                        sh "cd workspace && git pull origin main"
                    } else {
                        echo "Cloning repository..."
                        sh "git clone ${GIT_REPO} workspace"
                    }
                }
            }
        }

        stage("Build and Push Docker Image") {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: "dockerHub", usernameVariable: "DOCKER_USERNAME", passwordVariable: "DOCKER_PASSWORD")
                ]) {
                    sh """
                        cd workspace
                        echo "Building Docker image..."
                        docker build -t ${DOCKER_HUB_REPO}:latest .

                        echo "Logging in to Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

                        echo "Pushing image to Docker Hub..."
                        docker push ${DOCKER_HUB_REPO}:latest
                    """
                }
            }
        }

        stage("Deploy on EC2-2") {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: "ec2-ssh-key", keyFileVariable: "SSH_KEY"),
                    string(credentialsId: "EC2_2_IP", variable: "EC2_2_IP")
                ]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@\$EC2_2_IP << 'EOF'
                        set -e

                        echo "Updating system packages..."
                        sudo apt-get update -y || true
                        
                        echo "Installing Docker if not installed..."
                        if ! command -v docker &> /dev/null; then
                            sudo apt-get install -y docker.io
                        fi

                        echo "Installing Docker Compose if not installed..."
                        if ! command -v docker-compose &> /dev/null; then
                            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                            sudo chmod +x /usr/local/bin/docker-compose
                            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
                        fi
                        
                        echo "Fetching latest repo on EC2-2..."
                        if [ -d "${DEPLOY_DIR}" ]; then
                            cd ${DEPLOY_DIR}
                            git pull origin main
                        else
                            git clone ${GIT_REPO} ${DEPLOY_DIR}
                            cd ${DEPLOY_DIR}
                        fi

                        echo "Pulling latest Docker image..."
                        docker pull ${DOCKER_HUB_REPO}:latest

                        echo "Stopping old containers..."
                        docker-compose down --remove-orphans

                        echo "Deploying latest image..."
                        docker-compose up -d --force-recreate

                        echo "Cleaning up unused images..."
                        docker image prune -af

                        echo "Deployment successful!"
                        EOF
                    """
                }
            }
        }
    }
}
