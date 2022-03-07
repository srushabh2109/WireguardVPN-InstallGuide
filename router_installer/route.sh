#!/bin/bash

serviceFile="[Unit]\nDescriptionTech Josie LLC Webserver Router\n\n[Service]\nType=simple\nExecStart=/bin/bash $PWD/route.sh\n\n[Install]\nWantedBy=multi-user.target"

echo " Using current location. Do not move files!"

echo -e $serviceFile > /etc/systemd/system/network-router.service
result=$(find /etc/systemd/system/network-router.service)

if [ $result == "/etc/systemd/system/network-router.service" ]; 
    then
    echo " Service created successfully."
else
    echo "Failed to create service file. Copy this manually:"
    echo $serviceFile
    echo " Into -> /etc/systemd/system/network-router.service"
fi

echo " Reloading Daemon..."
sudo systemctl daemon-reload

echo " Enabling and Starting Service..."
sudo systemctl enable ddos-mitigation.service --now

echo " Done! :D"
exit
