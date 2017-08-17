pipeline {
    agent none
        
    stages {
        stage('Build 1') {
            agent { docker maven:3.5-jdk-7-alpine' }
            steps {
                sh "mvn clean package"
                junit './target/surefire-reports/**/*.xml'
            }
        }
        stage('Build 2') {
           agent any
           steps {
               script {
                   newImage = docker.build('petstore-tomcat')
               }
           }
        }
    }
}

