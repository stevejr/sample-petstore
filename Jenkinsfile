pipeline {
    agent any
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
    }

    stages {
        stage('Setup Env vars') {
            steps {
                script {
                    env.VCS_REF = sh (
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()
                        
                    env.BUILD_DATE = sh (
                        returnStdout: true,
                        script: 'date -u +"%Y-%m-%dT%H:%M:%SZ"'
                    ).trim()
                }
                echo "${env.VCS_REF}"
                echo "${env.BUILD_DATE}"
            }
        }
        stage('Build WAR') {
            agent {
                docker {
                    reuseNode true    //reuse the workspace on the agent defined at top-level\
                    image 'maven:3.5.0-jdk-8'
                }
            }
            steps {
                sh 'mvn -B -f pom.xml clean package'
                junit(allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml')
            }
        }
        stage('Quality Analysis') {
            steps {
                sh 'echo I will do some analysis one day!'
            } 
        }
        stage('Build Image') {
            steps {
                sh """
                    docker build --build-arg VCS_REF=${env.VCS_REF} /
                    --build-arg BUILD_DATE=${env.BUILD_DATE} /
                    -t ${IMAGE}:${VERSION}.${VCS_REF} .
                """
            }
        }
    }
    post {
        failure {    // notify users when the Pipeline fails
            mail(to: 'me@example.com', subject: "Failed Pipeline", body: "Something is wrong.")
        } 
    }
}
