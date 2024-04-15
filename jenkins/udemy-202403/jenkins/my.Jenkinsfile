pipeline {
    agent any
    parameters {
        booleanParam(name: 'skip_test', defaultValue: false, description: 'Skip Sonarqube Analysis?')
    }
    tools {
        maven 'maven3.9'
    }
    environment {
        registry = '221968583774.dkr.ecr.ap-northeast-1.amazonaws.com/springbootapp'
        registryCredential = 'jenkins-ecr-login-credentials'
        dockerimage = ''
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/melvincv/springboot-maven-micro.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage("Sonar Quality Check"){
            when {
                expression { params.skip_test != true }
            }
            steps{
                script{
                    withSonarQubeEnv(installationName: 'sonar', credentialsId: 'sonar-token') {
                        sh 'mvn sonar:sonar'
                    }
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage('Building the Image') {
            steps {
                script {
                dockerImage = docker.build registry + ":$BUILD_NUMBER"
                }
            }
        }
        stage ('Deploy the Image to Amazon ECR') {
            steps {
                script {
                    docker.withRegistry("https://" + registry, "ecr:ap-northeast-1:" + registryCredential ) {
                    dockerImage.push()
                    }
                }
            }
        }
        stage('CD Using Ansible') {
            steps {
                script {
                    ansiblePlaybook become: true, colorized: true, credentialsId: 'cd-server-creds', disableHostKeyChecking: true, extras: '-e BUILD_NUMBER=${BUILD_NUMBER}', inventory: 'ansible/inventory.ini', playbook: 'ansible/playbook.yml'
                }
            }
        }
    }
    post {
        success {
            mail bcc: '', body: 'Pipeline success', cc: '', from: 'xxxxxx@live.com', replyTo: '', subject: 'Pipeline success', to: 'xxxxxx@live.com'
        }
        failure {  
            mail bcc: '', body: 'Pipeline failed', cc: '', from: 'xxxxxx@live.com', replyTo: '', subject: 'Pipeline failed', to: 'xxxxxx@live.com'
        } 
    }
}
