peline {
    agent none
    environment {
        COMMIT_HASH = 'default'
    }   
    stages {
        stage('Build Dockerfile Multi-Stage') {
           agent any
           steps {
           // override with variable
                script {
                    sh 'git rev-parse HEAD > gitCommit'
                    def gitCommit = readFile('gitCommit').trim()
                    // short SHA, possibly better for chat notifications, etc.
                    def shortCommit = gitCommit.take(6)
                    withEnv(['COMMIT_HASH=' + shortCommit]) {
                        newImage = docker.build('petstore-tomcat:$COMMIT_HASH')
                    }
                }
            }
        }
    }
}
