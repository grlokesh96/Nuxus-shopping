
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'grlokesh96/nuxus-shopping'
    }

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

        stage('Build Application') {
            steps {
                sh '''
                    set -e
                    node --version
                    npm --version
                    npm ci
                    npm run build
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                    docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                        set -e
                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" --password-stdin

                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Build successful! Docker image pushed to Docker Hub.'
        }
        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
        always {
            sh 'docker image prune -f || true'
        }
    }
}
