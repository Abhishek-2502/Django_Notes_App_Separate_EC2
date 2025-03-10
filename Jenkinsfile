pipeline {
    agent any
    
    environment {
        IMAGE_NAME = "django-note-app"
        DOCKER_HUB_REPO = "abhi25022004/django-note-app"
    }

    stages {
        stage("Deploy on EC2-2 & Build Image") {
            steps {
                echo "Deploying on EC2-2 and building Docker image"
                withCredentials([
                    sshUserPrivateKey(credentialsId: "ec2-ssh-key", keyFileVariable: "SSH_KEY"),
                    usernamePassword(credentialsId: "dockerHub", usernameVariable: "DOCKER_USERNAME", passwordVariable: "DOCKER_PASSWORD"),
                    string(credentialsId: "EC2_2_IP", variable: "EC2_2_IP")
                ]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@\$EC2_2_IP << 'EOF'
                        set -e  # Stop execution if any critical command fails
                        
                        echo "Updating package list..."
                        sudo apt-get update -y || true
                        
                        echo "Checking if Docker is installed..."
                        if ! command -v docker &> /dev/null; then
                            echo "Docker not found, installing..."
                            sudo apt-get install -y docker.io || true
                        fi
                        
                        echo "Checking if Docker Compose is installed..."
                        if ! command -v docker-compose &> /dev/null; then
                            echo "Docker Compose not found, installing..."
                            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose || true
                            sudo chmod +x /usr/local/bin/docker-compose
                            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true
                        fi
                        
                        echo "Switching to home directory"
                        cd /home/ubuntu || true
                        
                        echo "Cloning or updating repository..."
                        if [ ! -d "Django_Notes_App_Docker_Jenkins_Declarative" ]; then
                            git clone https://github.com/Abhishek-2502/Django_Notes_App_Docker_Jenkins_Declarative.git || true
                        fi
                        cd Django_Notes_App_Docker_Jenkins_Declarative || true
                        git pull origin main || true
                        
                        echo "Cleaning up old Docker images..."
                        docker system prune -f || true
                        
                        echo "Building Docker image..."
                        docker build -t ${IMAGE_NAME} . || true
                        
                        echo "Logging in to Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin || true
                        
                        echo "Pushing image to Docker Hub..."
                        docker tag ${IMAGE_NAME} ${DOCKER_HUB_REPO}:latest || true
                        docker push ${DOCKER_HUB_REPO}:latest || true
                        
                        echo "Deploying with Docker Compose..."
                        docker-compose down || true
                        docker-compose up -d || true

                        echo "Deployment successful!"
                    """
                }
            }
        }
    }
}
