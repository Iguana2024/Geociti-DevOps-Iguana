#!/bin/bash

sudo apt update

sudo apt install -y wget ca-certificates

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

sudo apt install -y postgresql postgresql-contrib

sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
sudo sh -c "echo 'host	all         	all         	0.0.0.0/0           	md5' >> /etc/postgresql/12/main/pg_hba.conf"

sudo systemctl restart postgresql
PG_PASSWORD=$(<../pg_password.txt)
sudo -u postgres psql -c "CREATE USER citizen_iguana WITH PASSWORD '$PG_PASSWORD';"
sudo -u postgres psql -c "CREATE DATABASE citizen_db OWNER citizen_iguana;"

echo "host	citizen_db	citizen_iguana 	0.0.0.0/0	md5" | sudo tee -a /etc/postgresql/12/main/pg_hba.conf

sudo systemctl reload postgresql

sudo ufw allow 5432/tcp