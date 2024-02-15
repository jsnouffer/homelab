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
  storage:
    config:
    - {ptable: gpt, path: /dev/sda, wipe: superblock,
      preserve: false, name: '', grub_device: true, type: disk, id: disk-sda}
    - {device: disk-sda, size: 1MB, flag: bios_grub, number: 1, preserve: false,
      grub_device: false, type: partition, id: partition-0}
    - {device: disk-sda, size: 1GB, wipe: superblock, flag: '', number: 2,
      preserve: false, grub_device: false, type: partition, id: partition-1}
    - {fstype: ext4, volume: partition-1, preserve: false, type: format, id: format-0}
    - {device: disk-sda, size: -1, wipe: superblock, flag: '', number: 3,
      preserve: false, grub_device: false, type: partition, id: partition-2}
    - name: ubuntu-vg
      devices: [partition-2]
      preserve: false
      type: lvm_volgroup
      id: lvm_volgroup-0
    - {name: ubuntu-lv, volgroup: lvm_volgroup-0, size: -1, preserve: false,
      type: lvm_partition, id: lvm_partition-0}
    - {fstype: ext4, volume: lvm_partition-0, preserve: false, type: format, id: format-1}
    - {device: format-1, path: /, type: mount, id: mount-1}
    - {device: format-0, path: /boot, type: mount, id: mount-0}
