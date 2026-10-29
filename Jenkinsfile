pipeline {
    agent any

    stages {
        stage('Verify Pipeline') {
            steps {
                echo 'Jenkins pipeline is working!'
            }
        }

        stage('Checkout Code') {
            steps {
                checkout scm
                sh 'ls -la'
            }
        }
    }
}
