pipeline {
    agent any

    parameters {
        string(name: 'TERRAGRUNT_PATH', defaultValue: '', description: 'Path to Terragrunt module')
        booleanParam(name: 'DRY_RUN', defaultValue: false, description: 'Perform a dry run of Terragrunt destroy')
        string(name: 'GITHUB_ISSUE_LINK', defaultValue: '', description: 'Link to the related GitHub issue')
    }

    environment {
        GITHUB_TOKEN = credentials('github-token') // Assuming a stored GitHub token in Jenkins credentials
        TERRAGRUNT_FLAGS = ''
    }

    stages {
        stage('Setup') {
            steps {
                script {
                    if (params.DRY_RUN) {
                        env.TERRAGRUNT_FLAGS = '--terragrunt-plan-all --terragrunt-non-interactive'
                    } else {
                        env.TERRAGRUNT_FLAGS = '--terragrunt-non-interactive'
                    }
                }
                echo "Terragrunt Flags: ${env.TERRAGRUNT_FLAGS}"
                echo "GitHub Issue Link: ${params.GITHUB_ISSUE_LINK}"
            }
        }

        stage('Terragrunt Destroy') {
            steps {
                script {
                    echo "Running Terragrunt destroy on path: ${params.TERRAGRUNT_PATH}"
                    dir(params.TERRAGRUNT_PATH) {
                        // sh """
                        // terragrunt run-all destroy ${env.TERRAGRUNT_FLAGS}
                        // """
                        echo "terragrunt run-all destroy"
                    }
                }
            }
        }

        stage('Create GitHub PR') {
            when {
                expression { return !params.DRY_RUN }
            }
            steps {
                script {
                    def prTitle = "Destroy Resources for GitHub Issue: ${params.GITHUB_ISSUE_LINK}"
                    def prBody = "This PR represents the destroy of resources as requested in ${params.GITHUB_ISSUE_LINK}."

                    // sh """
                    // curl -X POST -H "Authorization: token ${env.GITHUB_TOKEN}" -d '{
                    //     "title": "${prTitle}",
                    //     "body": "${prBody}",
                    //     "head": "destroy-branch",
                    //     "base": "main"
                    // }' https://api.github.com/repos/<your-repo-owner>/<your-repo>/pulls
                    // """
                    echo "title prTitl"
                }
            }
        }
    }

    post {
        success {
            script {
                def successMessage = "Terragrunt destroy completed successfully for path: ${params.TERRAGRUNT_PATH} related to ${params.GITHUB_ISSUE_LINK}"
                echo successMessage
                // Notify or update GitHub PR about success if required
            }
        }
        failure {
            script {
                def failureMessage = "Terragrunt destroy failed for path: ${params.TERRAGRUNT_PATH} related to ${params.GITHUB_ISSUE_LINK}"
                echo failureMessage
                // Notify or update GitHub PR about failure if required
            }
        }
    }
}
