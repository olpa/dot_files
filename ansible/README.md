# Minimal Ansible Project

Runs `uname -a` on a specified host.

## Usage

```bash
ansible-playbook -i "hostname," playbook.yml
```

**Note:** The trailing comma is required for Ansible to treat the hostname as an inline inventory.

## Examples

```bash
# AWS instance
ansible-playbook -i "i-04308e7a2b0043d00," playbook.yml

# Hostname
ansible-playbook -i "server.example.com," playbook.yml

# IP address
ansible-playbook -i "192.168.1.100," playbook.yml
```
