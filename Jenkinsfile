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
                image: jenkins/inbound-agent:4.6-1
                args: ["\$(JENKINS_SECRET)", "\$(JENKINS_NAME)"]
                tty: true
              - name: docker
                image: docker:19.03.12
                command:
                  - cat
                tty: true
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
        stage('build'){
            steps{
                sh "mvn install -DskipTests"
            }
            post {
                success {
                    echo 'Archive arfifacts'
                    // archiveArifacts artifacts:'**/*.jar'
                    archiveArtifacts artifacts: '**/*.jar'
                }
            }
        }
        stage('unit test'){
            steps{
                sh 'mvn test'
            }
        }
        stage('sonarqube check'){
            steps{
                sh 'mvn checkstyle:checkstyle'
            }
        }
        stage("build & SonarQube analysis") {
          environment{
            scannerHome = tool 'sonar'
          }
          steps{
              withSonarQubeEnv('sonar') {
                //  sh 'mvn clean package sonar:sonar'
                sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=c0 \
                   -Dsonar.projectName=c0 \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/example/restservice/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
                '''
              }
          }
      }

      stage("Quality Gate"){
          steps{
          timeout(time: 1, unit: 'HOURS') {
            // waitForQualityGate abortedPipeline: true
            waitForQualityGate abortPipeline: true
            //   def qg = waitForQualityGate()
            //   if (qg.status != 'OK') {
                //   error "Pipeline aborted due to quality gate failure: ${qg.status}"
            //   }
          }
      }
      }
      stage("uploade to nexus"){
          steps{
            nexusArtifactUploader(
            nexusVersion: 'nexus3',
            protocol: 'http',
            nexusUrl: 'nexus2.zoowj.click:8081',
            groupId: 'QA',
            version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
            repository: 'c01-hosted',
            credentialsId: 'nexus',
            artifacts: [
                [artifactId: 'c0',
                 classifier: '',
                 file: 'target/rest-service-complete-0.0.1-SNAPSHOT.jar',
                 type: 'jar']
            ]
            )
          }
      }
      stage('Build Docker Image') {
            steps {
                script {
                    // Define Dockerfile location and image name
                    def dockerfile = 'Dockerfile'
                    def imageName = 'c0-app:tag'

                    // Build Docker image
                    docker.build(imageName, "-f ${dockerfile} .")
                }
            }
        }
        stage('Push to ECR') {
            steps {
                // Login to ECR
                script {
                    withAWS(credentials: 'aws_zhuwj2024001a001', region: AWS_REGION) {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                    }
                }
                
                // Tag Docker image
                script {
                    docker.image("c0-app:tag:${DOCKER_IMAGE_TAG}").tag("${ECR_REPO}:${DOCKER_IMAGE_TAG}")
                }
                
                // Push Docker image to ECR
                script {
                    docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com", 'ecr:us-east-1') {
                        docker.image("${ECR_REPO}:${DOCKER_IMAGE_TAG}").push()
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