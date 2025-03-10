pipeline {
    agent any
    
    environment {
        IMAGE_NAME = "django-note-app"
        DOCKER_HUB_REPO = "abhi25022004/django-note-app"
    }

    stages {
        stage("Clone Code") {
            steps {
                echo "Cloning the repository..."
                git url: "https://github.com/Abhishek-2502/Django_Notes_App_Docker_Jenkins_Declarative.git", branch: "main"
            }
        }

        stage("Build Image") {
            steps {
                echo "Building Docker image..."
                sh """
                    docker system prune -f  # Clean up old Docker resources
                    docker build -t ${IMAGE_NAME} .
                """
            }
        }

        stage("Push to Docker Hub") {
            steps {
                echo "Pushing image to Docker Hub..."
                withCredentials([usernamePassword(credentialsId: "dockerHub", passwordVariable: "DOCKER_PASSWORD", usernameVariable: "DOCKER_USERNAME")]) {
                    sh """
                        docker tag ${IMAGE_NAME} ${DOCKER_HUB_REPO}:latest
                        echo \$DOCKER_PASSWORD | docker login --username \$DOCKER_USERNAME --password-stdin
                        docker push ${DOCKER_HUB_REPO}:latest
                    """
                }
            }
        }

        stage("Deploy on EC2-2") {
            steps {
                echo "Deploying on EC2-2..."
                withCredentials([
                    sshUserPrivateKey(credentialsId: "ec2-ssh-key", keyFileVariable: "SSH_KEY"),
                    string(credentialsId: "EC2_2_IP", variable: "EC2_2_IP")
                ]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@\$EC2_2_IP << 'EOF'
                        echo "Pulling latest image..."
                        docker-compose pull
                        echo "Stopping old container..."
                        docker-compose down
                        echo "Starting new container..."
                        docker-compose up -d
                        echo "Deployment completed successfully!"
                        EOF
                    """
                }
            }
        }
    }
}
