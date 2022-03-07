# Wireguard VPN InstallGuide
Steps to setting up a VPN for a public server to hide it's IP address. 

This operation uses very little memory, so the VPN VPS doesn't require much power. Unlimited traffic is preferred.

# Requirements
- Server with access to the public internet
- Small/lightweight cloud VPS

Tested with: `Debian 9`, `Debian 10`, `Debian 11`, `Ubuntu 18 Server`, `Ubuntu 20 Server`

# Steps
Steps will need to be completed on the client (which is actually the server) and the server (which is acting as a router/VPN). If you see `[Client]`, that is a step for the local machine, this computer will act as a public server although there will be no ports open on it's local network. If you see the `[Server]` tag before the step, it needs to be completed on the VPS which is our router. Please be read with caution to avoid having to restart.

# [Server] Install WireGuard
```
sudo apt install wireguard -y
```

# [Server] Change to root and generate keys
```
sudo -i
cd /etc/wireguard/
umask 077; wg genkey | tee privatekey | wg pubkey > publickey
```

# [Server] Start creating the configuration file.
You will still need to add the client's public key, so once you paste this you aren't done in here yet, but you can save for now.
```
sudo nano wg0.conf
```
Paste this, and replace the `PrivateKey` under `[Interface]` with the private key generated in the previous step. If you type `cat *`, it will be the first string. Else if you're not feeling speedy you can `cat privatekey`.
```
[Interface]
PrivateKey = private-key-we-generated-in-previous-step
Address = 10.0.0.1/24
ListenPort = 42295

[Peer]
PublicKey = public-key-of-the-client
AllowedIPs = 10.0.0.2/24
```

# [Client] Install wireguard on the client and generate keys

Remember, the client is going to act as the server to the public internet, although technically in this setup, it is the client.
```
sudo apt install wireguard -y
sudo -i
cd /etc/wireguard/
umask 077; wg genkey | tee privatekey | wg pubkey > publickey
```

