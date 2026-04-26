pipeline {
    // This tells Jenkins to ONLY run this job on the Agent you just built
    agent { label 'mern-worker' } 

    stages {
        stage('Clone Code') {
            steps {
                // Pulls the latest code from your GitHub repo
                checkout scm 
            }
        }
        
        stage('Verify Worker Tools') {
            steps {
                // Proves the agent is working by checking Docker
                sh 'echo "Running on Agent: $NODE_NAME"'
                sh 'docker --version'
            }
        }
        
        // We will add the actual Docker build commands here next!
    }
}