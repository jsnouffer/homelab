import os
import sys
import json
import requests

vm_id: int = 7

TRUENAS_API_URL: str = "https://barenas.jsnouff.net/api/v2.0"

session = requests.Session()
session.headers.update({"Content-Type": "application/json"})
with open(os.path.expanduser("~/.truenas-api-key")) as api_key_file:
    session.headers.update({"Authorization": f"Bearer {api_key_file.read().strip()}"})

if vm_id <= 0:
    vm_create_data: dict = {
        "name": "ubuntu",
        "autostart": True,
        "cpu_mode": "HOST-MODEL",
        "vcpus": 2,
        "cores": 1,
        "threads": 2,
        "memory": 1024 * 4,
    }

    try:
        response = session.post(
            TRUENAS_API_URL + "/vm", verify=True, data=json.dumps(vm_create_data)
        )
        response.raise_for_status()
    except requests.exceptions.HTTPError as e:
        print(e, file=sys.stderr)
        print(json.dumps(response.json()))
        sys.exit(1)

    print(json.dumps(response.json()))
    vm_id: int = response.json()["id"]

vm_devices: dict = [
    {
        "vm": vm_id,
        "dtype": "CDROM",
        "attributes": {
            "path": "/mnt/sandbox/vm-images/ubuntu-22.04.2-desktop-amd64.iso",
        },
    },
    {
        "vm": vm_id,
        "dtype": "DISK",
        "attributes": {
            "path": "/dev/zvol/sandbox/vm-storage/ubuntu-c4fxfd",
            "type": "VIRTIO",
        },
    },
    {
        "vm": vm_id,
        "dtype": "NIC",
        "attributes": {
            "mac": "00:a0:98:39:5b:78",
            "type": "VIRTIO",
            "nic_attach": "enp42s0",
        },
    },
]

for vm_device in vm_devices:
    try:
        response = session.post(
            TRUENAS_API_URL + "/vm/device", verify=True, data=json.dumps(vm_device)
        )
        response.raise_for_status()
    except requests.exceptions.HTTPError as e:
        print(e, file=sys.stderr)
        print(json.dumps(response.json()))
        sys.exit(1)

    print(json.dumps(response.json()))
