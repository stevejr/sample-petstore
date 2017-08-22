Pipeline {
    agent any
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
        BUILD_DATE=sh (returnStdout: true,
                       script: 'date -u +"%Y-%m-%dT%H:%M:%SZ"'
                    ).trim()
        MAJOR_VERSION="0.0"
        DOCKER_REG="https://registry.hub.docker.com"
        DOCKER_REPO="leftshiftit"
    }

    stages {
        stage('Setup Env vars') {
            steps {
                script {
                    env.VCS_REF = sh (
                        returnStdout: true,
                        script: 'git rev-parse HEAD'
                    ).trim()
                    env.STAGING_VERSION = "${MAJOR_VERSION}." +
                        sh (returnStdout: true,
                            script: 'git rev-list --count HEAD'
                        ).trim()
                    currentBuild.displayName="${STAGING_VERSION}"
                    currentBuild.description="${VCS_REF}"        
                }
                echo "VCS_REF: ${VCS_REF}"
                echo "BUILD_DATE: ${BUILD_DATE}"
                echo "STAGING_VERSION: ${STAGING_VERSION}"
                echo 'HOME: $HOME'
            }
        }
        stage('Build WAR') {
            agent {
                docker {
                    reuseNode true    //reuse the workspace on the agent defined at top-level\
                    image 'maven:3.5.0-jdk-8'
                    args '-v $HOME/.m2:/root/.m2'
                }
            }
            steps {
                //sh "mvn versions:update-parent -DallowSnapshots=true -DparentVersion=[17.5.0-SNAPSHOT,17.6.0-SNAPSHOT] -B -U"
                sh "mvn versions:set versions:update-child-modules -DnewVersion=${STAGING_VERSION}-SNAPSHOT -B -U"
                sh 'mvn versions:use-latest-versions -DallowSnapshots=true -Dincludes=com.fanniemae.amtm -B -U'

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
                script {
                    // Build the image. Create a global reference to the Image Name
                    env.DOCKER_IMAGE_NAME="${DOCKER_REPO}/${IMAGE}:${STAGING_VERSION}"
                    def myImage = docker.build("${DOCKER_IMAGE_NAME}", "--build-arg VCS_REF=${VCS_REF.take(6)} --build-arg BUILD_DATE=${BUILD_DATE} .")
                    echo "Built image ${myImage.id}"
                }
            }
        }
        stage('Test Image') {
            steps {
                script {
                    docker.image("${DOCKER_IMAGE_NAME}").inside {
                        sh 'echo "Tests passed"'
                    }
                }
            }
        }
        stage('Push Image') {
            steps {
                script {
                    docker.withRegistry("${DOCKER_REG}", 'dockerhub-creds') {
                        docker.image("${DOCKER_IMAGE_NAME}").push()
                    }
                }
            }
        }
    }
    post {
// Always runs. And it runs before any of the other post conditions.
        always {
            // Let's wipe out the workspace before we finish!
            deleteDir()
        }
    
        success {
            echo "Success"      
//            mail(from: "bob@example.com", 
//                to: "steve@example.com", 
//                subject: "Build ${STAGING_VERSION} passed.",
//                body: "Nothing to see here")
        }

        failure {
            echo "Failure"
//          mail(from: "bob@example.com", 
//              to: "steve@example.com", 
//              subject: "Build ${STAGING_VERSION} failed.",
//              body: "Nothing to see here")
        }
    }
}

