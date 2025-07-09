# Jenkins Declarative Pipeline Setup (Multi-Instance Deployment)

This guide provides step-by-step instructions for setting up a Jenkins Declarative Pipeline to automate the build and deployment of a Django Notes App using Docker. Jenkins is installed on one instance, and the application is deployed on another instance via SSH.

---

## Prerequisites

Ensure you have the following installed and configured on an Instance:
- **Docker**
- **Docker Compose**
- **Docker Hub (If used in project)**
- **Jenkins**

Refer to the installation guide: [Java_Jenkins_Docker_Setup_Cloud](https://github.com/Abhishek-2502/Java_Jenkins_Docker_Setup_Cloud)

---

## 1. Create a Jenkins Project

1. Open Jenkins at `http://jenkins_instance_public_ip:8080`
2. Click **New Item**
3. Select **Pipeline**
4. Enter project name (e.g., `django-notes-remote-deploy`)
5. Click **OK**

---

## 2. Configure the Project

### General
- **Description**: Django Notes App deployment using declarative pipeline with SSH to remote Instance
- **GitHub Project**: Add repository URL

### Build Triggers
- Enable **GitHub hook trigger for GITScm polling**

### Pipeline
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: Enter your GitHub repo link
- **Branches to build**: `*/main`
- **Script Path**: `Jenkinsfile`

---

## 3. Add Docker Hub Credentials in Jenkins (If used in project)

1. Navigate to **Manage Jenkins** → **Manage Credentials**
2. Under **Stores scoped to Jenkins**, select **Global credentials (unrestricted)**
3. Click **Add Credentials**
4. Enter the following details:
   - **Kind**: Username with password
   - **Scope**: Global (Jenkins, nodes, items, all child items, etc.)
   - **ID**: `dockerHub`
   - **Description**: This is DockerHub credentials.
   - **Username**: DockerHub Username (e.g., `abhi25022004`)
   - **Password**: DockerHub Password
5. Click **OK**

---

## 4. Allow Port 8000 in Security Group, Firewall, etc

For accessing the Django Notes App, open port **8000** on Target Instance:
- **Type**: Custom TCP
- **Port Range**: 8000
- **Source**: Anywhere-IPv4

---

## 5. Automate Build with Webhooks

Refer to **Step 10** of the guide: [Node_Todo_App_Docker_Jenkins_FreeStyle](https://github.com/Abhishek-2502/Node_Todo_App_Docker_Jenkins_FreeStyle)

---

## 6. Running the Pipeline

Push some changes in the code on Github and pipeline will automatically build the app.

---

## 7. Verifying the Deployment

- Once the build is complete, the Django Notes App should be accessible at: 
  
  ```
  http://target_instance_public_ip:8000
  ```

---

### You’ve successfully created a Jenkins Declarative Pipeline to deploy a Django Notes App on a remote instance using SSH.

## Author
Abhishek Rajput


