pipeline {
    agent none
    stages {
        stage('Fluffy Build') {
            parallel {
                stage('Build Java 8') {
                    agent {
                        kubernetes {
                            label 'pl_mavenjdk8_build'
                            containerTemplate {
                                name 'maven'
                                image 'maven:3.3.9-jdk-8-alpine'
                                ttyEnabled true
                                command 'cat'
                            }
                        }
                    }
                    steps {
                        container('maven') {
                            sh 'mvn -v'
                        }
                    }
                }
                stage('Build Java 11') {
                    agent {
                        kubernetes {
                            label 'pl_mavenjdk11_build'
                            containerTemplate {
                                name 'mavenjdk11'
                                image 'maven:3-jdk-11-slim'
                                ttyEnabled true
                                command 'cat'
                            }
                        }
                    }
                    steps {
                        container('mavenjdk11') {
                            sh 'mvn -v'
                        }
                    }
                }
            }
        }
        stage('Fluffy Test') {
            parallel {
                stage('JDK 8') {
                    agent {
                        kubernetes {
                            label 'pl_mavenjdk8_test'
                            containerTemplate {
                                name 'maven'
                                image 'maven:3.3.9-jdk-8-alpine'
                                ttyEnabled true
                                command 'cat'
                            }
                        }
                    }
                    stages {
                        stage('Functional Tests') {
                            steps {
                                echo 'Hello'
                            }
                        }
                        stage('API Contract Tests') {
                            steps {
                                echo 'Hello'
                            }
                        }
                        stage('Performance Tests') {
                            when {
                                branch 'master'
                            }
                            steps {
                                echo 'Hello'
                            }
                        }
                    }
                }
                stage('JDK 11') {
                    agent {
                        kubernetes {
                            label 'pl_mavenjdk11_test'
                            containerTemplate {
                                name 'mavenjdk11'
                                image 'maven:3-jdk-11-slim'
                                ttyEnabled true
                                command 'cat'
                            }
                        }
                    }
                    stages {
                        stage('Functional Tests') {
                            steps {
                                echo 'Hello'
                            }
                        }
                        stage('API Contract Tests') {
                            steps {
                                echo 'Hello'
                            }
                        }
                        stage('Performance Tests') {
                            when {
                                branch 'master'
                            }
                            steps {
                                echo 'Hello'
                            }
                        }
                    }
                }
            }
        }
        stage('Fluffy Deploy') {
            agent {
                kubernetes {
                    label 'pl_declarative_deployment'
                    containerTemplate {
                        name 'pl_deployment'
                        image 'cloudbees/docker-java-with-docker-client'
                        ttyEnabled true
                        command 'cat'
                    }
                }
            }
            when {
                branch 'master'
                beforeAgent true
            }
            steps {
                echo "hello"
            }
        }
    }
}


