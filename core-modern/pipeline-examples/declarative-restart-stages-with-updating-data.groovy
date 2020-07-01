pipeline {
    agent any
    environment {
        FOO     = ''
        TESTS   = ''
        ANDROID = ''
        LINUX   = ''
    }
    stages {
        stage('Prep') {
            steps {
                println 'Hello World'
                script {
                    ANDROID = true
                    LINUX   = true
                    TESTS   = true
                }
            }
        }
        stage('Validate') {
            parallel {
                stage('Validate' ) {
                    environment {
                        TESTS   = "${TESTS}"
                        LINUX   = "${LINUX}"
                        ANDROID = "${ANDROID}"
                    }
                    stages {
                        stage('Validate Test Params' ) {
                            steps {
                                println "TESTS=${TESTS}"
                                println "LINUX=${LINUX}"
                                println "ANDROID=${ANDROID}"
                            }
                        }
                        stage('Reset Test Params') {
                            when {
                                equals expected: 'null', actual: TESTS
                                beforeInput true  
                            }
                            input {
                                message 'Test'
                                ok 'OK'
                                parameters {
                                    booleanParam defaultValue: false, description: 'Execute Linux tests', name: 'Linux'
                                    booleanParam defaultValue: false, description: 'Execute Android tests', name: 'Android'
                                }
                            }
                            steps {
                                println "LINUX=${Linux}"
                                println "ANDROID=${Android}"
                                script {
                                    LINUX   = "${Linux}"
                                    ANDROID = "${Android}"
                                    TESTS   = true
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('Tests') {
            when {
                expression { return TESTS }
            }
            parallel {
                stage('Linux' ) {
                    when {
                        equals expected: 'true', actual: "${LINUX}"
                        beforeAgent true
                    }
                    steps {
                        println "abc"
                    }
                }
                stage('Android' ) {
                    when {
                        equals expected: 'true', actual: "${ANDROID}"
                        beforeAgent true
                    }
                    steps {
                        println "abc"
                    }
                }
            }
        }
    }
}