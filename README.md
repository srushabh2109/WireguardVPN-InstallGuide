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
sudo nano /etc/wireguard/wg0.conf
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

# [Client] Now create, and fill the configuration file.
```
sudo nano /etc/wireguard/wg0.conf
```
Paste the below text into the file. By now you will have all this information you need to complete this file. First, replace the private key under `[Interface]` with the second privatekey we just generated. The interface section always refers to the machine you are editing the coniguration on. Next, you will need to copy the VPS' public key. You generated this earlier on the server. And finally, replace `server-ip` in the `Endpoint` value to the IP address of the VPS.
```
[Interface]
Address = 10.0.0.2/24
ListenPort = 42295
PrivateKey = private-key-we-generated-in-previous-step

[Peer]
PublicKey = public-key-of-the-server
AllowedIPs = 10.0.0.0/24
Endpoint = server-ip:42295
PersistentKeepalive = 15
```
Save and close.

# [Client] Start & Enable WireGuard
It will continue to try to connect, so don't worry about it being too early. Once we finish the config on the VPS it will be good to go.
```
sudo systemctl enable wg-quick@wg0 --now
```

# [Server] Fill out the client's public key, and enable settings
Back on the server, edit `sudo nano /etc/wireguard/wg0.conf`, and now replace the `PublicKey` value's variable with the public key you generated on the client. Then enable WireGuard.
```
sudo systemctl enable wg-quick@wg0 --now
```

# [Server] Finish configuration
There are only a couple more steps to complete our VPN routing network. First, we need to enable ip forwarding on the VPS (Server). If you aren't sure if it's already enabled you can check like so:
```
cat /etc/sysctl.conf | grep ipv4.ip_forward
```
If there is not a `#` in front, it is already enabled. If not, you need to edit this file and remove the `#` in front of it and make sure it is equal to 1.

Example: `#net.ipv4.ip_forward=1` -> `net.ipv4.ip_forward=1`

Now you need to tell it to route the connection on boot.

# [Server] Configuring the Router (It's simple, trust me)
This does come with a installer for the router service. The router service is written to route a webserver. If you plan to forward a port other than 80 or 443 to the VPN, just copy the first line and append before the last, while changing both instances of the port you wish to forward. 

# DO NOT PORT FORWARD 22! IT WILL MAKE IT DIFFICULT TO SSH INTO THE VPN ROUTER WITHOUT BEING FORWARDED TO THE CLIENT. 
IF YOU HAVE THIS APP FORWARD SSH, AND YOU TRY TO SSH INTO THE ROUTER, YOU WILL BE ACTUALLY CONNECTING TO THE CLIENT, AND FOR MAINTINENCE PURPOSES, YOU DO NOT WANT THAT. You can still access the client on port 22 through the VPN network, or if you are already connected to the router.

# [Server] Download and use installer
Now that the warnings are out of the way, let's get started. Make sure you're logged in on the VPS as root, and navigate to a scripts folder
```
sudo -i && cd
mkdir scripts && cd scripts
```

Download the installer, and routing script. 
```
wget https://raw.githubusercontent.com/techjosie/WireguardVPN-InstallGuide/main/router_installer/install-router.sh
wget https://raw.githubusercontent.com/techjosie/WireguardVPN-InstallGuide/main/router_installer/route.sh
```
If you need to forward anything other than a webserver, you will do this now. Edit `route.sh` and modify to your needs.

Now install.
```
chmod +x /root/scripts/*.sh
./install.sh
```

Check the status of the router to ensure it worked. It should not be running as it only needs to be ran once. This will run at each boot, and once completed it will stop itself. It should say loaded and succeeded with this command
```
sudo systemctl status network-router.service
```
