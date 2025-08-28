pipeline {
    agent any
    tools {
        nodejs 'nodejs'
    }

    stages {
        stage('Install dependencies') {
            steps {
                echo 'Installing dependencies'
                sh 'npm install'
            }
            post{
                success{
                    echo "Installation successful"
                }
                failure{
                    echo "Installation faild"
                }
            }
        }

        stage('Linter ESLint') {
            steps {
                echo 'Installing Linter ESLint'
                sh 'npm run lint'
            }
            post{
                success{
                    echo "Linter ESLint successful"
                }
                failure{
                    echo "Linter ESLint faild"
                }
            }
        }
        stage('Formatterx') {
            steps {
                echo 'Formatteing'
                sh 'npm run prettier -- ––write'
            }
            post{
                success{
                    echo "Formatter successful"
                }
                failure{
                    echo "Formatter faild"
                }
            }
        }
        stage('Test') {
            steps {
                echo 'Testing'
                sh 'CI=true npm run test'
            }
            post{
                success{
                    echo "Test successful"
                }
                failure{
                    echo "Test faild"
                }
            }
        }
        stage('Build') {
            steps {
                echo 'Building'
                sh 'npm run build'
            }
            post{
                success{
                    echo "Build successful"
                }
                failure{
                    echo "Build faild"
                }
            }
        }
        stage('Creating Infta Terraform') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_CRED', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('terraform'){
                        script{
                            //Terarform Init
                            sh 'terraform init -input=false'
                            // Terraform Plan
                            sh 'terraform paln -input=false '

                            // Terraform Apply

                            sh 'terraform apply -input=false -auto-approve tfplan'
                        }
                    }
                }
            }
            post{
                success{
                    echo "Infta is Success"
                }
                failure{
                    echo "Terraform faild"
                }
            }
        }               
        stage('Deploy to S3') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'AWS_CRED', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                 sh "aws s3 cp ./build/ s3://web-stack-test-bucket-tettssa/ --recursive"
                }
            }
            post{
                success{
                    echo "Copy build to s3"
                }
                failure{
                    echo "Copy build to S3 failed"
                }
            }
        }
    }
}
