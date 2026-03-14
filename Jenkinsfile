pipeline {
    agent any
    environment {
        IMAGE = "dockerhubusername/app:latest"
    }

    stages {

        stage('Checkout') {
            steps { git 'https://github.com/your/app.git' }
        }

        stage('Secret Scan') {
            steps {
                sh 'docker run --rm -v $(pwd):/repo zricethezav/gitleaks detect --source=/repo'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('OWASP Scan') {
            steps {
                sh 'dependency-check.sh --scan .'
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t $IMAGE .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'trivy image --exit-code 1 --severity CRITICAL,HIGH $IMAGE'
            }
        }

        stage('Push Image') {
            steps {
                sh 'docker push $IMAGE'
            }
        }

        stage('Update Manifest Repo') {
            steps {
                sh '''
                git clone https://github.com/your/k8s-manifest.git
                cd k8s-manifest
                sed -i 's|image:.*|image: dockerhubusername/app:latest|' deployment.yaml
                git commit -am "image update"
                git push
                '''
            }
        }
    }
}