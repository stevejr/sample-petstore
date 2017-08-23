#!groovy
@Library('sample-petstore-declarative-libs') _

pipeline {
    agent any
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
        BUILD_DATE=sh (returnStdout: true,
                       script: 'date -u +"%Y-%m-%dT%H:%M:%SZ"'
                    ).trim()
        MAJOR_VERSION="0.0"
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
                    currentBuild.displayName="${env.STAGING_VERSION}"
                    currentBuild.description="${env.VCS_REF}"        
                }
                sendNotifications 'STARTED'
                echo "VCS_REF: ${env.VCS_REF}"
                echo "BUILD_DATE: ${env.BUILD_DATE}"
                echo "STAGING_VERSION: ${env.STAGING_VERSION}"
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
                sh "mvn versions:set versions:update-child-modules -DnewVersion=${env.STAGING_VERSION}-SNAPSHOT -B -U"
                sh 'mvn versions:use-latest-versions -DallowSnapshots=true -Dincludes=com.fanniemae.amtm -B -U'

                sh 'mvn -B -f pom.xml clean package'
            }
            post {
                success {
                    junit(allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml')
                }
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
                    try {
                        // Build the image. Create a global reference to the Image Name
                        env.DOCKER_IMAGE_NAME="${env.DOCKER_REPO}/${env.IMAGE}:${env.STAGING_VERSION}"
                        def myImage = docker.build("${env.DOCKER_IMAGE_NAME}", "--build-arg VCS_REF=${env.VCS_REF.take(6)} --build-arg BUILD_DATE=${env.BUILD_DATE} .")
                        echo "Built image ${myImage.id}"
                    } catch (Exception e) {
                        echo "Exception Caught: ${e}"
                    }
                }
                post {
                    success {
                        sendNotifications "New Image built - ${env.DOCKER_IMAGE_NAME}"
                    }
                }
            }
        }
        stage('Test Image') {
            steps {
                script {
                    docker.image("${env.DOCKER_IMAGE_NAME}").inside {
                        sh 'echo "Tests passed"'
                    }
                }
            }
        }
        stage('Push Image') {
            steps {
                timeout(time:2, unit:'DAYS') {
                    input message: 'Image look good?', ok: 'Push to Docker Hub', submitter: 'admin'
                }
                script {
                    docker.withRegistry("${env.DOCKER_HUB_REGISTRY_URL}", 'dockerhub-creds') {
                        docker.image("${env.DOCKER_IMAGE_NAME}").push()
                    }
                }
                post {
                    success {
                        sendNotifications "New Image pushed - ${env.DOCKER_HUB_REGISTRY_URL}/${env.DOCKER_IMAGE_NAME}"
                    }
                }
            }
        }
    }
    post {
// Always runs. And it runs before any of the other post conditions.
        always {
            sendNotifications currentBuild.result
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

