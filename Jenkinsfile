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

stage('Terraform Fix Protection') {
    steps {
        dir('terraform') {
            withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                sh '''
                export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS

                terraform init
                terraform apply -auto-approve -var="project_id=devops-demo-project-491008"
                '''
            }
        }
    }
}

stage('Terraform Destroy Old Infra') {
    steps {
        dir('terraform') {
            withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                sh '''
                export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS

                terraform destroy -auto-approve -var="project_id=devops-demo-project-491008"
                '''
            }
        }
    }
}
    }
}
