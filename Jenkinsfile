pipeline {
    agent any

    environment {
        IMAGE_NAME = "django-note-app"
    }

    stages {
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
                        
                        echo "Updating system packages..."
                        sudo apt-get update -y || true
                        
                        echo "Ensuring repository is up-to-date..."
                        if [ -d "/home/ubuntu/Django_Notes_App_Separate_EC2" ]; then
                            cd /home/ubuntu/Django_Notes_App_Separate_EC2
                            git fetch origin main
                            git reset --hard origin/main
                        else
                            git clone https://github.com/Abhishek-2502/Django_Notes_App_Separate_EC2.git /home/ubuntu/Django_Notes_App_Separate_EC2
                            cd /home/ubuntu/Django_Notes_App_Separate_EC2
                        fi

                        echo "Stopping old containers..."
                        docker-compose down --remove-orphans
			
		        echo "Building the image"
			docker-compose build

                        echo "Deploying latest image..."
                        docker-compose up -d

                        echo "Cleaning up unused images..."
                        docker image prune -af

                        echo "Deployment successful!"
                        
                    """
                }
            }
        }
    }
}
