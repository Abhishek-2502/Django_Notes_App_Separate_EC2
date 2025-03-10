pipeline {
    agent any

    environment {
        IMAGE_NAME = "django-note-app"
        DOCKER_HUB_REPO = "abhi25022004/django-note-app"
    }

    stages {
        stage("Clone Repo on EC2-2") {
            steps {
                echo "Cloning GitHub repository on EC2-2"
                withCredentials([
                    sshUserPrivateKey(credentialsId: "ec2-ssh-key", keyFileVariable: "SSH_KEY"),
                    string(credentialsId: "EC2_2_IP", variable: "EC2_2_IP")
                ]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@\$EC2_2_IP << 'EOF'
                        set -e
                        echo "Checking for existing repo..."
                        cd /home/ubuntu || exit 1
                        if [ ! -d "Django_Notes_App_Docker_Jenkins_Declarative" ]; then
                            git clone https://github.com/Abhishek-2502/Django_Notes_App_Docker_Jenkins_Declarative.git
                        fi
                        cd Django_Notes_App_Docker_Jenkins_Declarative
                        git pull origin main
                        exit 0
                        EOF
                    """
                }
            }
        }

        stage("Build & Push Docker Image") {
            steps {
                echo "Building and pushing Docker image"
                withCredentials([
                    sshUserPrivateKey(credentialsId: "ec2-ssh-key", keyFileVariable: "SSH_KEY"),
                    usernamePassword(credentialsId: "dockerHub", usernameVariable: "DOCKER_USERNAME", passwordVariable: "DOCKER_PASSWORD"),
                    string(credentialsId: "EC2_2_IP", variable: "EC2_2_IP")
                ]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@\$EC2_2_IP << 'EOF'
                        set -e
                        echo "Switching to project directory..."
                        cd /home/ubuntu/Django_Notes_App_Docker_Jenkins_Declarative || exit 1

                        echo "Cleaning old Docker images..."
                        docker system prune -f || true

                        echo "Building Docker image..."
                        docker build -t ${IMAGE_NAME} . || exit 1

                        echo "Logging in to Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin || exit 1

                        echo "Pushing Docker image..."
                        docker tag ${IMAGE_NAME} ${DOCKER_HUB_REPO}:latest
                        docker push ${DOCKER_HUB_REPO}:latest
                        exit 0
                        EOF
                    """
                }
            }
        }

        stage("Deploy with Docker Compose") {
            steps {
                echo "Deploying application with Docker Compose"
                withCredentials([
                    sshUserPrivateKey(credentialsId: "ec2-ssh-key", keyFileVariable: "SSH_KEY"),
                    string(credentialsId: "EC2_2_IP", variable: "EC2_2_IP")
                ]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@\$EC2_2_IP << 'EOF'
                        set -e
                        echo "Switching to project directory..."
                        cd /home/ubuntu/Django_Notes_App_Docker_Jenkins_Declarative || exit 1

                        echo "Checking Docker Compose installation..."
                        if ! command -v docker-compose &> /dev/null; then
                            echo "Installing Docker Compose..."
                            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                            sudo chmod +x /usr/local/bin/docker-compose
                            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true
                        fi

                        echo "Stopping existing containers..."
                        docker-compose down || true

                        echo "Starting new deployment..."
                        docker-compose up -d
                        
                        echo "Deployment successful!"
                        exit 0
                        EOF
                    """
                }
            }
        }
    }
}
