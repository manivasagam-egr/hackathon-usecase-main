pipeline {
    agent any

    environment {
        PROJECT_ID = "devops-demo-project-491008"
        REGION = "us-central1"
        REPO = "my-repo-1"
        IMAGE_NAME = "my-app"
    }

    stages {

        // -----------------------------
        // INFRA (Terraform)
        // -----------------------------
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh '''
                        export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS
                        terraform init
                        terraform apply -auto-approve -var="project_id=$PROJECT_ID"
                        '''
                    }
                }
            }
        }

        // -----------------------------
        // BUILD (Node + Maven)
        // -----------------------------
        stage('Build') {
            steps {
                sh '''
                echo "Building Node app"
                cd app
                npm install || true

                echo "Building Java app"
                mvn clean package || true
                '''
            }
        }

        // -----------------------------
        // TEST
        // -----------------------------
        stage('Test') {
            steps {
                sh '''
                echo "Running tests"
                npm test || true
                mvn test || true
                '''
            }
        }

        // -----------------------------
        // DOCKER BUILD
        // -----------------------------
        stage('Docker Build') {
            steps {
                sh '''
                docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:latest .
                '''
            }
        }

        // -----------------------------
        // PUSH TO ARTIFACT REGISTRY
        // -----------------------------
        stage('Push Image') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                    export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS

                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
                    gcloud auth configure-docker $REGION-docker.pkg.dev -q

                    docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO/$IMAGE_NAME:latest
                    '''
                }
            }
        }

        // -----------------------------
        // DEPLOY TO GKE
        // -----------------------------
        stage('Deploy to GKE') {
            steps {
                withCredentials([file(credentialsId: 'gcp-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                    export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS

                    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

                    gcloud container clusters get-credentials devops-cluster --region $REGION

                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }

        // -----------------------------
        // VERIFY
        // -----------------------------
        stage('Verify Deployment') {
            steps {
                sh '''
                kubectl get pods
                kubectl get svc
                '''
            }
        }
    }
}
