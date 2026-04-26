pipeline {
    // Ensuring this runs on your specific AWS Agent node
    agent { label 'mern-worker' } 

    environment {
        // Your Docker Hub username
        DOCKER_USER = 'ramday' 
    }

    stages {
        stage('Clone Code') {
            steps {
                // Pulls the MERN code from your private GitHub repo
                checkout scm 
            }
        }
        
        stage('Build Docker Images') {
            steps {
                script {
                    // Navigate to backend folder and build
                    dir('backend') {
                        sh "docker build -t ${DOCKER_USER}/mern-backend:latest ."
                    }
                    // Navigate to frontend folder and build
                    dir('frontend') {
                        sh "docker build -t ${DOCKER_USER}/mern-frontend:latest ."
                    }
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                // 'dockerhub-creds' must match the ID you gave in Jenkins Credentials
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER_ID')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER_ID --password-stdin"
                    
                    // Pushing both images to your ramday account
                    sh "docker push ${DOCKER_USER}/mern-backend:latest"
                    sh "docker push ${DOCKER_USER}/mern-frontend:latest"
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                // Optional: Removes local images from the agent to save disk space
                sh "docker rmi ${DOCKER_USER}/mern-backend:latest ${DOCKER_USER}/mern-frontend:latest"
            }
        }
    }
}