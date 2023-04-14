// def COLOR_MAP = [
//     'SUCCESS': 'good',
//     'FAILURE': 'danger',
// ]

// def getBuildUser() {
//     return currentBuild.rawBuild.getCause(Cause.UserIdCause).getUserId()
// }

/* groovylint-disable-next-line CompileStatic */
pipeline {
    agent any

    // options {
    //     ansiColor('xterm')
    // }

    tools {
        maven 'Maven'
    }

    environment {
        /* groovylint-disable-next-line UnnecessaryGetter */
        ArtifactId = readMavenPom().getArtifactId()
        /* groovylint-disable-next-line UnnecessaryGetter */
        Version = readMavenPom().getVersion()
        /* groovylint-disable-next-line UnnecessaryGetter */
        GroupId = readMavenPom().getGroupId()
        /* groovylint-disable-next-line UnnecessaryGetter */
        Name = readMavenPom().getName()
        /* groovylint-disable-next-line ConsecutiveStringConcatenation, DuplicateStringLiteral */
        NameFolder = "${env.BUILD_ID}" + '.' + "${ env.GIT_COMMIT[0..6] }"

        // doError = '0'

        // BUILD_USER = ''
    }

    stages {
        stage('Build') {
            steps {
                sh "sed -i 's|<version>0.0.1</version>|<version>${env.NameFolder}</version>|g' pom.xml"
                sh 'mvn clean install package'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }

        stage('Publish to Nexus') {
            steps {
                script {
                    /* groovylint-disable-next-line NoDef, VariableName, VariableTypeRequired */
                    def NexusRepo = Version.endsWith('SNAPSHOT') ? 'MyLab-SNAPSHOT' : 'MyLab-RELEASE'
                    nexusArtifactUploader artifacts:
                    [
                        [
                            artifactId: "${ArtifactId}",
                            classifier: '',
                            file: "target/${ArtifactId}-${env.NameFolder}.war",
                            type: 'war'
                        ]
                    ],
                    credentialsId: 'Nexus',
                    groupId: "${GroupId}",
                    nexusUrl: '13.215.12.135:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: "${NexusRepo}",
                    version: "${env.NameFolder}"
                }
            }
        }
        stage('Print Environment variables') {
            steps {
                echo "Artifact ID is '${ArtifactId}'"
                echo "Group ID is '${GroupId}'"
                echo "Version is '${Version}'"
                echo "Name is '${Name}'"
                echo "Name of folder is '${NameFolder}'"
            }
        }
        stage('Deploy to Docker') {
            steps {
                echo 'Deploying...'
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'Ansible',
                            transfers: [
                                sshTransfer(
                                    cleanRemote: false,
                                    execCommand: 'cd playbooks/ && ansible-playbook playbook.yml -i inventory.txt',
                                    execTimeout: 120000,
                                    flatten: false,
                                    makeEmptyDirs: false,
                                    noDefaultExcludes: false,
                                    patternSeparator: '[, ]+',
                                    remoteDirectory: '/playbooks',
                                    remoteDirectorySDF: false,
                                    removePrefix: '',
                                    sourceFiles: 'playbook.yml, inventory.txt'
                                )
                            ],
                            usePromotionTimestamp: false,
                            useWorkspaceInPromotion: false,
                            verbose: false
                        )
                    ]
                )
            }
        }
    }

    post {
        always {
            script {
                /* groovylint-disable-next-line NoDef, VariableTypeRequired */
                def slackToken = 'Slack'
                /* groovylint-disable-next-line NoDef, VariableTypeRequired */
                def slackChannel = '#general'

                /* groovylint-disable-next-line NoDef, VariableTypeRequired */
                def commitMessage = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
                /* groovylint-disable-next-line NoDef, VariableTypeRequired */
                def commitAuthor = sh(returnStdout: true, script: 'git log -1 --pretty=%an').trim()
                /* groovylint-disable-next-line NoDef, VariableTypeRequired */
                def commitHash = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()

                /* groovylint-disable-next-line LineLength, NoDef, VariableTypeRequired */
                def message = "New commit by ${commitAuthor}: ${commitMessage} - <https://github.com/mhviet2001/CI-CD-Pipeline-Java-WebApp/commit/${commitHash}|${commitHash}>"

                slackSend(token: slackToken, channel: slackChannel, message: message)
            }
        }
    }
}
