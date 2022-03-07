# Forward ports to make the client into a webserver. Adjust ports as necessary
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.2:80
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 10.0.0.2:443
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
