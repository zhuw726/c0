pipeline{
    agent {
        kubernetes {
            // Define the label for the Kubernetes agent
            label 'my-kubernetes-agent'

            // Define the Docker image to use for the Kubernetes agent pod
            defaultContainer 'jnlp'

            // Define pod templates for the Kubernetes agent
            yaml """
            apiVersion: v1
            kind: Pod
            metadata:
              labels:
                jenkins: my-kubernetes-agent
            spec:
              containers:
              - name: jnlp
                image: jenkins/inbound-agent:alpine-jdk17
                args: ["\$(JENKINS_SECRET)", "\$(JENKINS_NAME)"]
                tty: true
              - name: docker
                image: docker:19.03.12
                command:
                  - cat
                tty: true
                securityContext:
                  privileged: true
            """

            // Define additional pod templates if needed
            // You can specify multiple pod templates for different types of agents
        }
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
        jdk "JDK17"
        // sonar "sonar"
    }
    environment {
        // Set AWS credentials with appropriate permissions
        // AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        // AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_ACCOUNT_ID = '590183952641'
        AWS_REGION = 'us-east-1'
        ECR_REPO = 'zoowj-repo'
        DOCKER_IMAGE_TAG = 'latest'
    }
    stages{
        stage('get code'){
            steps{
                git branch: 'main', url: 'https://github.com/zhuw726/c0.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    container('docker') {
                        sh 'dockerd & > /dev/null'
                        sleep(time: 20, unit: "SECONDS")
                        sh 'docker --version'
                        // Define Dockerfile location and image name
                        def dockerfile = 'Dockerfile'
                        def imageName = 'c0-app:tag'
    
                        // Build Docker image
                        docker.build(imageName, "-f ${dockerfile} .")
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                // Send Slack notification on build success
                slackSend channel: 'jenkins-cicd-notifycaiton', color: 'good', message: "Build successful: ${currentBuild.fullDisplayName}"
            }
        }
        failure {
            script {
                // Send Slack notification on build failure
                slackSend channel: 'jenkins-cicd-notifycaiton', color: 'danger', message: "Build failed: ${currentBuild.fullDisplayName}"
            }
        }
    }
}