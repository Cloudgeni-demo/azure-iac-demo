# Description
Install wordpress with high available azure infrastructure.

1. Clone the project:
    ```
    # git clone git@github.com:vimuchiaroni/azure-wordpress-ha.git
    ```
2. Go to the terraform directory:
    ```
    # cd terraform
    ```
3. Install az cli by following Microsoft steps: https://learn.microsoft.com/pt-br/cli/azure/install-azure-cli

4. Login to azure:
    ```
    # az login
    ```
5. Run terraform:
    ```
    # terraform init
    # terraform plan -out plan.json
    # terraform apply plan.json
    ```
