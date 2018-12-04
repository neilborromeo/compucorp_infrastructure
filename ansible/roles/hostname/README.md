### Ansible role for hostname definition

Configration role
  ```
  ---
   - hosts: all
     connection: local
     user: root
     roles:
      - hostname
  ```

Usage example

  `ansible-playbook -i ec2.py hostname.yml`

and if you want, you can limit the execution just to change a specific host hostname's:

eg.: to limit to a specific host that has a tag called "hostname" with the value "testing01"

  `ansible-playbook -i ec2.py hostname.yml --limit tag_hostname_testing01`

