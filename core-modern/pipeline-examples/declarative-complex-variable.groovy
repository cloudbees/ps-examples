pipeline {
    agent any
    environment {
        FOO = '' //placeholder
    }
    stages {
        stage('Test one') {
            steps {
                // println "FOO=${FOO}" would fail, as empty var doesn't exist
                script {
                    FOO = ['Something Else']
                }
            }
        }
        stage ('Test two') {
            steps {
                println "FOO=${FOO}"
                script {
                    for (entry in FOO) {
                        println "entry=${entry}"
                    }
                }
            }
        }
    }
}
