pipeline{
    agent any
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "M3"
        jdk "JDK17"
        sonarqube "SONAR"
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
    }
}