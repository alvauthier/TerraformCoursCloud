#!/bin/bash

sudo apt update
sudo apt install git docker.io docker-compose-v2 nodejs npm nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

cd /var/www/html
sudo mkdir vue
cd vue
sudo git clone https://github.com/Benoitapps/ChallengeS2.git
cd ChallengeS2
sudo docker compose up -d
sudo npm install -g pm2

cd backend
sudo npm install

sudo rm .env
sudo cp /home/Alexandre/back.env /var/www/html/vue/ChallengeS2/backend/.env
sudo cp /var/www/html/vue/ChallengeS2/backend/.env /var/www/html/vue/ChallengeS2/backend/.env.local

# cd ChallengeS2/backend

pm2 start npm --name "backend" -- start

cd ..
cd frontend
sudo npm install

sudo rm .env
sudo cp /home/Alexandre/front.env /var/www/html/vue/ChallengeS2/frontend/.env
sudo cp /var/www/html/vue/ChallengeS2/frontend/.env /var/www/html/vue/ChallengeS2/frontend/.env.local

sudo npm run build

sudo cp /home/Alexandre/default /etc/nginx/sites-available/default


# sudo cp nginx.conf /etc/nginx/sites-available/default

sudo systemctl restart nginx
