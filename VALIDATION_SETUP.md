# Validation Workflow Setup Required

This PR adds a `tags` variable to `main.tf`. To enable automated validation, the following GitHub Actions workflow file needs to be created:

## File: `.github/workflows/terraform-validate.yml`

```yaml
name: Cloudgeni Terraform Validate
on:
  workflow_dispatch:
    inputs:
      working_directory:
        description: "Terraform working directory"
        default: "terraform"

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init
        working-directory: ${{ inputs.working_directory }}

      - name: Terraform Validate
        run: terraform validate
        working-directory: ${{ inputs.working_directory }}

      - name: Terraform Plan
        run: |
          terraform plan -out=tfplan
          terraform show -json tfplan > plan.json
        working-directory: ${{ inputs.working_directory }}
        env:
          ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
          ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
          ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}

      - uses: actions/upload-artifact@v4
        with:
          name: terraform-plan
          path: ${{ inputs.working_directory }}/plan.json
```

## Why This File Cannot Be Added Automatically

The GitHub App integration lacks `workflows` permission, preventing automated creation of workflow files. This workflow file must be added manually or with appropriate credentials.

## Next Steps

1. Create the workflow file at the path specified above
2. Ensure GitHub secrets are configured: `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`
3. Merge this PR to the main branch
4. The validation pipeline is already registered in Cloudgeni and will be available once the workflow file exists

## Cloudgeni Pipeline Configuration

The validation pipeline has been registered with the following configuration:
- **Pipeline ID**: `pip_8NWrcQ8TbGcqYI5fEAf8tq2SF9qb`
- **Slug**: `e2e-tf-validate`
- **Environment**: `dev`
- **Working Directory**: `terraform`
