pipeline {
    agent any

    stages {

        stage('Test') {
            steps {
                echo 'Jenkins connected successfully'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init
                    terraform plan
                    '''
                }
            }
        }
    }
}