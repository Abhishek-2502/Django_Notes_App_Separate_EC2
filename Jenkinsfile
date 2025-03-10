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
                        
                        echo "Updating package list..."
                        sudo apt-get update -y || true
                        
                        echo "Checking if Docker and Docker Compose are installed..."
                        if ! command -v docker &> /dev/null; then
                            sudo apt-get install -y docker.io
                        fi
                        if ! command -v docker-compose &> /dev/null; then
                            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                            sudo chmod +x /usr/local/bin/docker-compose
                            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
                        fi
                        
                        echo "Switching to project directory"
                        cd /home/ubuntu || true
                        if [ ! -d "Django_Notes_App_Docker_Jenkins_Declarative" ]; then
                            git clone https://github.com/Abhishek-2502/Django_Notes_App_Docker_Jenkins_Declarative.git
                        fi
                        cd Django_Notes_App_Docker_Jenkins_Declarative
                        git pull origin main
                        
                        echo "Logging in to Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin
                        
                        echo "Pulling latest image from Docker Hub..."
                        docker pull ${DOCKER_HUB_REPO}:latest
                        
                        echo "Deploying with Docker Compose..."
                        docker-compose down || true
                        docker-compose up -d

                        echo "Deployment successful!"
                    """
                }
            }
        }
    }
}
