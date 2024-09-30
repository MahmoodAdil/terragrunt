pipeline {
    agent any

    parameters {
        string(name: 'TERRAGRUNT_PATH', defaultValue: '', description: 'Path to Terragrunt module')
        booleanParam(name: 'DRY_RUN', defaultValue: false, description: 'Perform a dry run of Terragrunt destroy')
        string(name: 'GITHUB_ISSUE_LINK', defaultValue: '', description: 'Link to the related GitHub issue')
    }

    environment {
        GITHUB_TOKEN = credentials('LocalJenkinsGitToken') // Assuming a stored GitHub token in Jenkins credentials
    }

    stages {
        stage('Setup') {
            steps {
                script {
                    // Set TERRAGRUNT_FLAGS based on the value of DRY_RUN
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
                        echo "terragrunt run-all destroy ${env.TERRAGRUNT_FLAGS}"
                    }
                }
            }
        }

        stage('Create GitHub Branch (Optional)') {
            when {
                expression { return !params.DRY_RUN }
            }
            steps {
                script {
                    // Create a branch if it doesn't exist already (optional)
                    def branchName = "destroy-branch"
                    sh """
                    git checkout -b ${branchName} || git checkout ${branchName}
                    git push origin ${branchName}
                    """
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
                    def createPrCommand = """
                    curl -X POST -H "Authorization: token ${env.GITHUB_TOKEN}" -H "Content-Type: application/json" \
                    -d '{
                        "title": "${prTitle}",
                        "body": "${prBody}",
                        "head": "destroy-branch",
                        "base": "main"
                    }' https://api.github.com/repos/MahmoodAdil/terragrunt/pulls
                    """

                    // Execute the curl command and log the response
                    echo "Creating GitHub PR with title: ${prTitle}"
                    def response = sh(script: createPrCommand, returnStdout: true).trim()
                    echo "GitHub PR Response: ${response}"
                }
            }
        }
    }

    post {
        success {
            script {
                def successMessage = "Terragrunt destroy completed successfully for path: ${params.TERRAGRUNT_PATH} related to ${params.GITHUB_ISSUE_LINK}"
                echo successMessage
            }
        }
        failure {
            script {
                def failureMessage = "Terragrunt destroy failed for path: ${params.TERRAGRUNT_PATH} related to ${params.GITHUB_ISSUE_LINK}"
                echo failureMessage
            }
        }
    }
}
