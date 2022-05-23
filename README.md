# publish-chart-kubesphere

This GitHub Action copies a folder from the current repository to a location in another repository and create a pull request

## Example Workflow
    name: Pulish Helm chart to KubeSphere

    on: push

    jobs:
      publish:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout
          uses: actions/checkout@v2  # checkout repo where helm chart present in root directory

        - name: Create pull request
          uses: kethavathsivanaik/publish-chart-kubesphere@v1
          env:
            API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
          with:
            chart_dir: 'chart' 
            user_email: 'sivanaikk0903@gmail.com'
            user_name: 'kethavathsivanaik'   
            pull_request_reviewers: siva
## Variables
* chart_dir:path to helm chart directory. Example: install/kubernetes/helm/meshery/
* user_email: The GitHub user email associated with the API token secret.
* user_name: The GitHub username associated with the API token secret.
* pull_request_reviewers: [optional] The pull request reviewers. It can be only one (just like 'reviewer') or many (just like 'reviewer1,reviewer2,...')

## ENV
* API_TOKEN_GITHUB: You must create a personal access token in you account. Follow the link:
- [Personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)

> You must select the scopes: 'repo = Full control of private repositories', 'admin:org = read:org' and 'write:discussion = Read:discussion'; 
