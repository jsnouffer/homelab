#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: us
  ssh:
    install-server: true
    allow-pw: true
  refresh-installer:
    update: true
    channel: stable
  user-data:
    timezone: America/New_York
    disable_root: false
    package_update: true
    package_upgrade: false
    ssh_deletekeys: false
    users:
      - name: ${ username }
        passwd: ${ password }
        groups: [adm, sudo]
        lock-passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
  apt:
    preserve_sources_list: false
    mirror-selection:
      primary:
        - uri: http://us.archive.ubuntu.com/ubuntu/
        - uri: http://archive.ubuntu.com/ubuntu/
        - uri: http://ports.ubuntu.com/ubuntu-ports/
    fallback: abort
    geoip: true
  early-commands:
    - systemctl stop ssh
  late-commands:
    - curtin in-target -- apt-get update
    - curtin in-target -- apt-get install -y qemu-guest-agent
    - curtin in-target -- systemctl enable qemu-guest-agent
    - curtin in-target -- sed -i -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
