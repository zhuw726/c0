pipeline{
    // agent {
        // kubernetes {
        //     // Define the label for the Kubernetes agent
        //     label 'my-kubernetes-agent'

        //     // Define the Docker image to use for the Kubernetes agent pod
        //     defaultContainer 'jnlp'

        //     // Define pod templates for the Kubernetes agent
        //     yaml """
        //     apiVersion: v1
        //     kind: Pod
        //     metadata:
        //       labels:
        //         jenkins: my-kubernetes-agent
        //     spec:
        //       containers:
        //       - name: jnlp
        //         image: jenkins/inbound-agent:alpine-jdk17
        //         args: ["\$(JENKINS_SECRET)", "\$(JENKINS_NAME)"]
        //         tty: true
        //       - name: docker
        //         image: docker:19.03.12
        //         command:
        //           - cat
        //         tty: true
        //         securityContext:
        //           privileged: true
        //     """

        //     // Define additional pod templates if needed
        //     // You can specify multiple pod templates for different types of agents
        // }
    // }
    agent {
      kubernetes {
        label 'promo-app'  // all your pods will be named with this prefix, followed by a unique id
        idleMinutes 5  // how long the pod will live after no jobs have run on it
        yamlFile 'build-pod.yaml'  // path to the pod definition relative to the root of our project 
        defaultContainer 'maven'  // define a default container if more than a few stages use it, will default to jnlp container
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
                   // sh "docker build -t vividlukeloresch/promo-app:dev ."  // when we run docker in this step, we're running it via a shell on the docker build-pod container, 
                   // sh "docker push vividlukeloresch/promo-app:dev"        // which is just connecting to the host docker deaemon
                    sh "docker ps" 
                    sh "docker build -t custom-jenkins ." 
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