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
                    docker build --build-arg VCS_REF=${VCS_REF.take(6)} \
                    --build-arg BUILD_DATE=${BUILD_DATE} \
                    -t ${IMAGE}:${STAGING_VERSION} .
                """
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
            mail(from: "bob@example.com", 
                to: "steve@example.com", 
                subject: "Build ${STAGING_VERSION} passed.",
                body: "Nothing to see here")
        }

        failure {
          mail(from: "bob@example.com", 
              to: "steve@example.com", 
              subject: "Build ${STAGING_VERSION} failed.",
              body: "Nothing to see here")
        }
    }
}
