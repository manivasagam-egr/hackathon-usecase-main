pipeline {
    agent any

    environment {
        PROJECT_ID = 'devops-demo-project-491008'
        REGION = 'asia-south1'
    }

    stages {

        stage('Test') {
            steps {
                echo 'Jenkins connected successfully'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                        export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS

                        terraform init
                        terraform plan -var="project_id=$PROJECT_ID"
                        terraform apply -auto-approve -var="project_id=$PROJECT_ID"
                        '''
                    }
                }
            }
        }
    }
}