pipeline {
    agent any
    environment {
        FOO = 'BAR'
    }
    stages {
        stage('Interpolation') {
            steps {
                // not a good practice, costs more resources
                sh "echo foo=$FOO"
            }
        }
        stage('Use Target Agent Env') {
            steps {
                // best practice, leverage env variable on target agent
                sh 'echo foo=$FOO'
            }
        }
    }
}
