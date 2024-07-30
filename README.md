# RobotFlow Infrastructure

This repository contains infrastructure code for [RobotFlow](robotflow.ai)

## Get-Started

Install Ansible

```shell
pip install ansible-core
pip install ansible-lint
```

Install plugins

```shell
ansible-galaxy collection install -r requirements.yml
```

Create a inventory file

```ini
# inventory/dev.ini
[dev]
127.0.0.1 ansible_ssh_user=test ansible_ssh_port=22 ansible_sudo_pass=test
```

Run playbooks

```shell
ansible-playbook -i inventory/dev.ini playbooks/workstaion/...
```

## Setup Script

The `scripts/workstation/setup.bash` can be used to quickly bootstrap a host with openssh-server, create admin user and configure hostname.

```shell
curl -sSL https://raw.githubusercontent.com/robotflow-initiative/infrastructure/main/scripts/common/setup.bash -o setup.bash
sudo bash setup.bash
```

## Catalog

TBD.

## TODO

- [ ] Test rke2 server with nvidia_container and external_containerd and docker compatibility
- [ ] Test playbook/rke2
- [ ] Add more content about k8s apps
- [ ] Test auth/ldap playbook
- [ ] Update Catalog
