# Contributing to HybridOps Terraform Git Modules

This repository contains Git-sourced Terraform modules for Proxmox VMs and
LXCs. Contributions should keep the modules portable, predictable, and easy to
validate.

## Before you start

Open an issue before adding a module family, changing a module contract, or
introducing new provider behaviour. Direct pull requests are welcome for
contained fixes, examples, and documentation improvements.

## Scope and conventions

- Keep modules free of backend configuration, workspace assumptions, and
  provider authentication logic.
- Define and document all user-facing inputs and outputs.
- Keep examples aligned with the released module behaviour.
- Avoid private addresses, credentials, and environment-specific defaults.
- Preserve tagged, Git-based module consumption through `?ref=<tag>`.

## Validate the change

Run formatting from the repository root:

```bash
terraform fmt -check -recursive
```

Validate each changed module without configuring a backend:

```bash
cd proxmox/<module>
terraform init -backend=false -input=false
terraform validate -no-color
```

## Pull requests

Keep each pull request focused and explain the problem, the change, and the
validation performed. Update the module README and examples when an interface
or user-visible behaviour changes.

## Security

Do not include credentials, tokens, private addresses, or vulnerability details
in a public issue or pull request. For a suspected security issue, use the
[HybridOps contact form](https://hybridops.tech/contact?intent=general&source=gitmods-contributing&target=Security%20report&return=https%3A%2F%2Fdocs.hybridops.tech%2Fguides%2Freference%2Fcontributing%2F).
