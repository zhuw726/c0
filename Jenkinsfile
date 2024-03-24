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
        // stage('sonarqube Analysis'){
        //     steps{
        //         withSonarQubeEnv('SonarQubeServer') {
        //             sh 'sonar-scanner'
        //         }
        //     }
        // }

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
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
                '''
              }
          }
      }

    //   stage("Quality Gate"){
    //       timeout(time: 1, unit: 'HOURS') {
    //           def qg = waitForQualityGate()
    //           if (qg.status != 'OK') {
    //               error "Pipeline aborted due to quality gate failure: ${qg.status}"
    //           }
    //       }
    //   }
    }
}