# RobotFlow Ansible Playbooks

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

## Catalog

TBD.

## TODO

- [ ] Test rke2 server with nvidia_container and external_containerd and docker compatibility
- [ ] Test playbook/rke2
- [ ] Test auth/ldap playbook
- [ ] Update Catalog
