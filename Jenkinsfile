/* groovylint-disable-next-line CompileStatic */
pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

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
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean install package'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }

        stage('Retrieve Commit Information') {
            steps {
                script {
                    /* groovylint-disable-next-line VariableTypeRequired */
                    def gitCommit = sh(returnStdout: true, script: 'git log -1 --pretty=format:"%h - %an, %s"').trim()
                    env.GIT_COMMIT_MESSAGE = gitCommit
                }
            }
        }
        stage('Send Message to Slack') {
            steps {
                script {
                    def status = currentBuild.result == 'SUCCESS' ? 'succeeded' : 'failed'
                    def color = currentBuild.result == 'SUCCESS' ? 'good' : 'danger'
                    /* groovylint-disable-next-line LineLength */
                    slackSend channel: '#general', tokenCredentialId: 'Slack', color: color, message: "Build ${status} - New commit: ${env.GIT_COMMIT_MESSAGE}"
                }
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
                            file: "target/${ArtifactId}-${Version}.war",
                            type: 'war'
                        ]
                    ],
                    credentialsId: 'Nexus',
                    groupId: "${GroupId}",
                    nexusUrl: '13.215.12.135:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: "${NexusRepo}",
                    version: "${Version}"
                }
            }
        }
        stage('Print Environment variables') {
            steps {
                echo "Artifact ID is '${ArtifactId}'"
                echo "Group ID is '${GroupId}'"
                echo "Version is '${Version}'"
                echo "Name is '${Name}'"
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
}
