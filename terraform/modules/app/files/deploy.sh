#!/bin/bash
# download and run app
cd ~
git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
sudo cp /tmp/reddit.service /etc/systemd/system/
sudo systemctl enable reddit.service
sudo systemctl start reddit.service

