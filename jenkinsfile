// =============================================================================
// Build & Test -> Docker Build -> Push to Docker Hub
//
// Required plugins : Pipeline, Git, NodeJS, Credentials Binding, Timestamps
// Agent requirements: Docker CLI + access to the Docker daemon, git
// Jenkins tools    : NodeJS installation named 'NodeJS-20'
// Credentials      : dockerhub-credentials (Username with password)
// Job type         : Multibranch Pipeline (so pull requests are detected)
// =============================================================================

pipeline {

    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    tools {
        nodejs 'NodeJS-20'
    }

    environment {
        DOCKERHUB_IMAGE = 'lokeshzenbook/node-nuxus'
    }

    stages {

        // ---------- Stage 1: Checkout ----------
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.IMAGE_TAG = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
                }
                echo "Image tag: ${env.IMAGE_TAG}"
            }
        }

        // ---------- Stage 2: Build & Test ----------
        stage('Build & Test') {
            steps {
                sh 'node --version && npm --version'
                sh 'npm ci'
                sh 'npm run build'
                sh 'npm test --if-present'
            }
        }

        // ---------- Stage 3: Docker Build ----------
        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t $DOCKERHUB_IMAGE:$IMAGE_TAG \
                      -t $DOCKERHUB_IMAGE:latest \
                      .
                '''
            }
        }

        // ---------- Stage 4: Push to Docker Hub ----------
        stage('Push to Docker Hub') {
            when {
                not { changeRequest() }     // skip on pull requests
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                                                  usernameVariable: 'DOCKERHUB_USERNAME',
                                                  passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh 'echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin'
                }
                sh '''
                    docker push $DOCKERHUB_IMAGE:$IMAGE_TAG
                    docker push $DOCKERHUB_IMAGE:latest
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
            sh 'docker image rm $DOCKERHUB_IMAGE:$IMAGE_TAG $DOCKERHUB_IMAGE:latest || true'
        }
        success {
            echo "✅ Pipeline succeeded: $DOCKERHUB_IMAGE:${env.IMAGE_TAG}"
        }
        failure {
            echo '❌ Pipeline failed: check the stage logs above'
        }
    }
}
