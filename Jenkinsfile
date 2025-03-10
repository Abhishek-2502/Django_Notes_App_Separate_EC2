pipeline {
    agent any

    environment {
        IMAGE_NAME = "django-note-app"
        DOCKER_HUB_REPO = "abhi25022004/django-note-app"
    }

    stages {
        stage("Deploy on EC2-2") {
            steps {
                echo "Deploying latest image on EC2-2"
                withCredentials([
                    sshUserPrivateKey(credentialsId: "ec2-ssh-key", keyFileVariable: "SSH_KEY"),
                    string(credentialsId: "EC2_2_IP", variable: "EC2_2_IP"),
                    usernamePassword(credentialsId: "dockerHub", usernameVariable: "DOCKER_USERNAME", passwordVariable: "DOCKER_PASSWORD")
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
                        
                        echo "Ensuring repository is up-to-date..."
                        if [ -d "/home/ubuntu/Django_Notes_App_Separate_EC2" ]; then
                            cd /home/ubuntu/Django_Notes_App_Separate_EC2
                            git fetch origin main
                            git reset --hard origin/main
                        else
                            git clone https://github.com/Abhishek-2502/Django_Notes_App_Separate_EC2.git /home/ubuntu/Django_Notes_App_Separate_EC2
                            cd /home/ubuntu/Django_Notes_App_Separate_EC2
                        fi

                        echo "Building Docker image..."
                        docker build -t ${DOCKER_HUB_REPO}:latest .

                        echo "Logging in to Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

                        echo "Pushing image to Docker Hub..."
                        docker push ${DOCKER_HUB_REPO}:latest

                        echo "Stopping old containers..."
                        docker-compose down --remove-orphans

                        echo "Deploying latest image..."
                        docker-compose up -d --build

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
