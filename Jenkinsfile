pipeline {
    agent any

    environment {
        IMAGE_NAME = "django-note-app"
        DOCKER_HUB_REPO = "abhi25022004/django-note-app"
    }

    stages {
        stage("Clone Repo & Build Image") {
            steps {
                echo "Cloning GitHub repository and building Docker image"
                withCredentials([
                    usernamePassword(credentialsId: "dockerHub", usernameVariable: "DOCKER_USERNAME", passwordVariable: "DOCKER_PASSWORD")
                ]) {
                    sh """
                        echo "Cloning repository..."
                        rm -rf Django_Notes_App_Separate_EC2 || true
                        git clone https://github.com/Abhishek-2502/Django_Notes_App_Separate_EC2.git
                        cd Django_Notes_App_Separate_EC2
                        
                        echo "Building Docker image..."
                        docker build -t ${DOCKER_HUB_REPO}:latest .

                        echo "Logging in to Docker Hub..."
                        echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin < /dev/null
                        
                        echo "Pushing image to Docker Hub..."
                        docker push ${DOCKER_HUB_REPO}:latest
                    """
                }
            }
        }

        stage("Deploy on EC2-2") {
            steps {
                echo "Deploying latest image on EC2-2"
                withCredentials([
                    sshUserPrivateKey(credentialsId: "ec2-ssh-key", keyFileVariable: "SSH_KEY"),
                    string(credentialsId: "EC2_2_IP", variable: "EC2_2_IP")
                ]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ubuntu@\$EC2_2_IP << 'EOF'
                        set -e
                        
                        echo "Ensuring necessary packages are installed..."
                        sudo apt-get update -y || true
                        
                        if ! command -v docker &> /dev/null; then
                            sudo apt-get install -y docker.io
                        fi
                        if ! command -v docker-compose &> /dev/null; then
                            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
                            sudo chmod +x /usr/local/bin/docker-compose
                            sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
                        fi
                        
                        echo "Switching to project directory..."
                        cd /home/ubuntu/Django_Notes_App_Separate_EC2 || { 
                            git clone https://github.com/Abhishek-2502/Django_Notes_App_Separate_EC2.git && cd Django_Notes_App_Separate_EC2; 
                        }

                        echo "Pulling latest Docker image..."
                        docker-compose pull

                        echo "Deploying using rolling update strategy..."
                        docker-compose up -d --no-deps --build django-app

                        echo "Cleaning up unused images..."
                        docker image prune -af

                        echo "Deployment successful!"
                    """
                }
            }
        }
    }
}
