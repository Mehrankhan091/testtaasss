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
                sh 'npm run prettier ––write'
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


    }
}
