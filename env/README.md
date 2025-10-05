This workspace uses a consolidated root `provider.tf` and `locals.tf`.

How to run Terraform (per environment)

- Default var-file is `env/dev/terraform.tfvars`.

Wrapper script (recommended):

- Use `./scripts/tf <plan|apply|destroy>` which will prompt and default to `env/dev/terraform.tfvars`.
- Examples:
  - `./scripts/tf plan` (prompts, then runs `terraform plan -var-file=env/dev/terraform.tfvars`)
  - `./scripts/tf apply env/prod/terraform.tfvars --auto-approve`

Makefile shortcuts:

- `make plan` - runs `./scripts/tf plan env/dev/terraform.tfvars`
- `make apply` - runs `./scripts/tf apply env/dev/terraform.tfvars --auto-approve`
- `make destroy` - runs `./scripts/tf destroy env/dev/terraform.tfvars --auto-approve`

Notes:
- You can pass a different var-file as the first positional argument, or use `--var-file <path>`.
- The script prompts for confirmation; answer `Y` or `n`.
- Ensure you run `terraform init` at least once in the environment directory before plan/apply/destroy.
