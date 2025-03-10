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
                        
                        # Ensure the repository exists or clone it
                        cd /home/ubuntu
                        if [ ! -d "Django_Notes_App_Docker_Jenkins_Declarative" ]; then
                            echo "Repository not found. Cloning..."
                            git clone https://github.com/Abhishek-2502/Django_Notes_App_Docker_Jenkins_Declarative.git
                        fi
                        
                        # Navigate to project directory and pull latest changes
                        cd Django_Notes_App_Docker_Jenkins_Declarative
                        git pull origin main
                        
                        # Clean up old Docker images
                        docker system prune -f
                        
                        # Build the Docker image
                        docker build -t ${IMAGE_NAME} .
                        
                        # Login to Docker Hub
                        echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin
                        
                        # Push the image to Docker Hub
                        docker tag ${IMAGE_NAME} ${DOCKER_HUB_REPO}:latest
                        docker push ${DOCKER_HUB_REPO}:latest
                        
                        # Deploy using Docker Compose
                        docker-compose down
                        docker-compose up -d

                        EOF
                    """
                }
            }
        }
    }
}
