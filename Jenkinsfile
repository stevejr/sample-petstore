pipeline {
    agent any
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
        BUILD_DATE=sh (returnStdout: true,
                       script: 'date -u +"%Y-%m-%dT%H:%M:%SZ"'
                    ).trim()
        MAJOR_VERSION="0.0"
    }

    stages {
        stage('Setup Env vars') {
            steps {
                script {
                    env.VCS_REF = sh (
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()
                    env.STAGING_VERSION = "${MAJOR_VERSION}." +
                        sh (returnStdout: true,
                            script: 'git rev-list --count HEAD'
                        ).trim()
                    currentBuild.displayName="${env.STAGING_VERSION}"
                    currentBuild.description="${env.GIT_COMMIT}"        
                }
                echo "VCS_REF: ${VCS_REF}"
                echo "BUILD_DATE: ${BUILD_DATE}"
                echo "STAGING_VERSION: ${STAGING_VERSION}"
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
                sh """
                    docker build --build-arg VCS_REF=${env.VCS_REF} \
                    --build-arg BUILD_DATE=${env.BUILD_DATE} \
                    -t ${IMAGE}:${STAGING_VERSION} .
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
