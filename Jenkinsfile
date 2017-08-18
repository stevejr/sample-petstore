pipeline {
    agent any
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
    }

    stages {
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
                sh 'git rev-parse --short HEAD > commit'
                def VCS_REF  = readFile('commit').trim()
                sh """
                    docker build --build-arg VCS_REF=${VCS_REF} \
                        --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
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
