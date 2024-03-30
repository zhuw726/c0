pipeline{
    agent any
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
        jdk "JDK17"
        // sonar "sonar"
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
            nexusUrl: 'nexus.zoowj.click:8081',
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