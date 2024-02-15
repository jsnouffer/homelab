import argparse
from urllib.parse import urlparse

from proxmoxer import ProxmoxAPI

parser = argparse.ArgumentParser()
parser.add_argument("--url")
parser.add_argument("--username")
parser.add_argument("--password")
parser.add_argument("--id")
args = parser.parse_args()

proxmox_host: str = urlparse(args.url).netloc

proxmox = ProxmoxAPI(proxmox_host, user=args.username, password=args.password, verify_ssl=False)

id_components: list[str] = args.id.split("/")
print(f"Rebooting VM {args.id}")
proxmox.nodes(id_components[0]).qemu(id_components[2]).status.reboot.post()
