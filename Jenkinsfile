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
                    sh 'git rev-parse --short HEAD > commit'
                    env.VCS_REF = readFile('commit').trim()
                    env.BUILD_DATE = sh 'date -u +"%Y-%m-%dT%H:%M:%SZ"'
                }
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
                    docker build --build-arg VCS_REF=${env.VCS_REF} \
                        --build-arg BUILD_DATE=${env.BUILD_DATE} \
                        -t ${IMAGE} .
                    docker tag ${IMAGE} ${IMAGE}:${VERSION}.${VCS_REF}
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
