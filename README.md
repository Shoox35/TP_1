# TP1 – Terraform, Ansible & CI/CD

## Structure

- `terraform/` : Infrastructure as Code (Azure)
- `ansible/`   : Configuration des VMs via Ansible
- `.gitlab-ci.yml` : Pipeline GitLab CI/CD

## Prérequis

- Azure CLI (`az`)
- Compte Azure + variables CI/CD configurées
- Clé SSH publique ajoutée dans Terraform

## Usage

1. Pousse sur `main` pour déclencher `validate`, `plan` puis `apply` (manuellement).
2. Ensuite, `deploy` configurera tes VMs via Ansible.
