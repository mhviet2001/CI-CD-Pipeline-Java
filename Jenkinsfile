def COLOR_MAP = ['SUCCESS': 'good', 'FAILURE': 'danger', 'UNSTABLE': 'danger', 'ABORTED': 'danger']

pipeline {
    agent any

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
                echo 'echo Build'
                sh "sed -i 's|<version>0.0.1</version>|<version>${env.NameFolder}</version>|g' pom.xml"
                sh 'mvn clean install package'
            }
        }

        stage('Publish to Nexus') {
            steps {
                echo 'Publish to Nexus'
                script {
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

        stage('Deploy to Docker') {
            steps {
                echo 'Deploy to Docker'
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
                slackSend color: 'good', message: "*Build and deploy successful* :white_check_mark:\n\nJob: `*${env.JOB_NAME}*`\nBuild Number: `(<${env.BUILD_URL} |${env.BUILD_NUMBER}>)`\nCommit: `${commit[2]}`\nAuthor: `${commit[1]}`\nCommit ID: `${commit[0]}`", channel: '#general'
            }
        }

        failure {
            script {
                def commit = sh(returnStdout: true, script: 'git log --format="%H%n%an%n%s" -n 1').trim().split('\n')
                slackSend color: 'danger', message: "*Build or deploy failed* :x:\n\nJob: `*${env.JOB_NAME}*`\nBuild Number: `(<${env.BUILD_URL} |${env.BUILD_NUMBER}>)`\nCommit: `${commit[2]}`\nAuthor: `${commit[1]}`\nCommit ID: `${commit[0]}`", channel: '#general'
            }
        }

        // always {
        //     script {
        //         slackSend channel: "#general", color: COLOR_MAP[currentBuild.currentResult], message: "*`${currentBuild.currentResult}`*: *${env.JOB_NAME}*, build #${env.BUILD_NUMBER} \nRun in ${currentBuild.durationString} - (<${env.BUILD_URL} |Go to this job>) \nGit Branch:main"
        //     }
        // }
    }
}
