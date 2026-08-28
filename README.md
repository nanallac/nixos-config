# onboarding new nixos host
## sops
1. execute `ssh root@<ip-address> "cat /etc/ssh/ssh_host_ed25519_key.pub" | ssh-to-age` (note: update location if different)
2. edit .sops.yaml adding the result to keys: key and updating the creation_rules section.
3. run `sops updatekeys ./secrets/secrets.yaml`

# infrastructure

## machines

### Home Network & Infrastructure
- Router
  - Hostname: OpenWrt
  - OS: OpenWRT
  - Model: FriendlyElec NanoPi R4S
  - IP: 192.168.1.1
- Switch
  - Model: TP-Link TL-SG3424P
  - IP: 192.168.1.20
- Wireless AP
  - Model: TP-Link EAP620 HD
  - IP: 192.168.1.30
- Server (PC)
  - Hostname: moose
  - OS: NixOS
  - IP: 192.168.1.40
- Server (VPS)
  - Hostname: squid
  - OS: NixOS
  - IP: 175.45.180.229
- Server (PC)
  - Hostname: bison
  - OS: NixOS
  - IP: 192.168.1.233
- Server (PC)
  - Hostname: otter
  - OS: Proxmox
  - IP: 192.168.1.120
- VM
  - IP: 192.168.1.100
  - OS: TrusNAS Scale
- Server (PC)
  - Hostname: akita
  - OS: Proxmox
  - IP: 192.168.1.110
- VM
  - IP: 192.168.1.186
  - OS: HAOS
  - Hostname: homeassistant

### Media Devices
- Set Top Box
  - IP:
  - Model: Google Streamer 4k
- Music Speaker
  - IP: 192.168.1.171
  - Hostname: finch
  - OS: NixOS

### IP Cameras


### Josh Devices
- Laptop
  - IP: 192.168.1.132
  - Hostname: koala
  - OS: NixOS
- Laptop
  - IP: 192.168.1.196
  - Hostname: tapir
  - OS: Nixos
- Mobile
  - IP: 192.168.1.167
  - OS: GrapheneOS
  - Hostname: eagle

### Sydney Devices
- Laptop
  - OS: macOS
- Phone
  - OS: iOS
- Tablet
  - OS: iOS
