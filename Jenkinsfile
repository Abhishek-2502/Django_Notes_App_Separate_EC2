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
                        set -e
                        
                        echo "Switching to home directory"
                        cd /home/ubuntu
                        
                        echo "Cloning or updating repository..."
                        if [ ! -d "Django_Notes_App_Docker_Jenkins_Declarative" ]; then
                            git clone https://github.com/Abhishek-2502/Django_Notes_App_Docker_Jenkins_Declarative.git
                        fi
                        cd Django_Notes_App_Docker_Jenkins_Declarative
                        git pull origin main
                        
                        echo "Cleaning up old Docker images..."
                        docker system prune -f
                        
                        echo "Building Docker image..."
                        docker build -t ${IMAGE_NAME} .
                        
                        echo "Logging in to Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin
                        
                        echo "Pushing image to Docker Hub..."
                        docker tag ${IMAGE_NAME} ${DOCKER_HUB_REPO}:latest
                        docker push ${DOCKER_HUB_REPO}:latest
                        
                        echo "Deploying with Docker Compose..."
                        sudo /usr/local/bin/docker-compose down || true
                        sudo /usr/local/bin/docker-compose up -d

                        echo "Deployment successful!"
                        exit 0
                        EOF
                    """
                }
            }
        }
    }
}
