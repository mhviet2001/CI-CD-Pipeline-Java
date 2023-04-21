/* groovylint-disable ConsecutiveStringConcatenation, NoDef, UnnecessaryGetter, VariableTypeRequired */
pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    tools {
        maven 'Maven'
    }

    environment {
        ArtifactId = readMavenPom().getArtifactId()
        Version = readMavenPom().getVersion()
        GroupId = readMavenPom().getGroupId()
        Name = readMavenPom().getName()
        NameFolder = "${env.BUILD_ID}" + '.' + "${ env.GIT_COMMIT[0..6] }"
    }

    stages {
        stage('Build') {
            steps {
                sh "echo '\033[34mBuild\033[0m'"
                sh "sed -i 's|<version>0.0.1</version>|<version>${env.NameFolder}</version>|g' pom.xml"
                sh 'mvn clean install package'
            }
        }

        stage('Publish to Nexus') {
            steps {
                echo '\033[34mPublish\033[0m \033[33mto\033[0m \033[35mNexus\033[0m'
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
                echo '\033[34mDeploy\033[0m \033[33mto\033[0m \033[35mDocker\033[0m'
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
        success {
            script {
                def commit = sh(returnStdout: true, script: 'git log --format="%H%n%an%n%s" -n 1').trim().split('\n')
                slackSend color: 'good', message: "*Build and deploy successful* :white_check_mark:\n\nJob: `${env.JOB_NAME}`\nBuild Number: `${env.BUILD_NUMBER}`\nCommit: `${commit[2]}`\nAuthor: `${commit[1]}`\nCommit ID: `${commit[0]}`", channel: '#general'
            }
        }

        failure {
            script {
                def commit = sh(returnStdout: true, script: 'git log --format="%H%n%an%n%s" -n 1').trim().split('\n')
                slackSend color: 'danger', message: "*Build or deploy failed* :x:\n\nJob: `${env.JOB_NAME}`\nBuild Number: `${env.BUILD_NUMBER}`\nCommit: `${commit[2]}`\nAuthor: `${commit[1]}`\nCommit ID: `${commit[0]}`", channel: '#general'
            }
        }
    }
}
