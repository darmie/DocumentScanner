apt-get update
apt-get install -y git
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs
apt-get install -y build-essential
npm install -g npm
apt-get update
apt-get upgrade -y
apt-get autoremove -y


# Create logs directory
#su - vagrant -c "mkdir /vagrant/system/logs"

# Install Nginx
apt-get install -y nginx

# Create backup copy of existing config files (nginx.conf and mime.types)
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
cp /etc/nginx/mime.types /etc/nginx/mime.types.bak

# Create symlink to Nginx H5BP configuration files
#mkdir /etc/nginx/conf
mkdir /vagrant
#ln -sf /vagrant/system/nginx/nginx.conf /etc/nginx/nginx.conf
#ln -sf /vagrant/system/nginx/mime.types /etc/nginx/mime.types
#ln -s /vagrant/system/nginx/h5bp.conf /etc/nginx/conf/h5bp.conf
#ln -s /vagrant/system/nginx/x-ua-compatible.conf /etc/nginx/conf/x-ua-compatible.conf
#ln -s /vagrant/system/nginx/expires.conf /etc/nginx/conf/expires.conf
#ln -s /vagrant/system/nginx/cross-domain-fonts.conf /etc/nginx/conf/cross-domain-fonts.conf
#ln -s /vagrant/system/nginx/protect-system-files.conf /etc/nginx/conf/protect-system-files.conf

# Symlink to the proper log directory
#ln -s /var/log/nginx /usr/share/nginx/logs

# Configure default site using server.conf
#mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
#ln -s /vagrant/system/nginx/server.conf /etc/nginx/sites-available/default

# Create upstart job for Node.js app and Nginx
#cp /vagrant/system/upstart/app.conf /etc/init/app.conf
#cp /vagrant/system/upstart/nginx.conf /etc/init/nginx.conf    

# Install python packager
sudo apt-get install -y python-pip 


# Install opencv python package
cd ~
cd /vagrant
pip install --upgrade pip
pip install opencv-contrib-python
sudo apt-get install -y python-skimage

#install PM2 to run node server
sudo npm install -g pm2
pm2 startup systemd
#sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u Damilare --hp /home/ubuntu

#setup Redis
cd ~
sudo wget http://download.redis.io/redis-stable.tar.gz
sudo tar xvzf redis-stable.tar.gz
cd redis-stable
make
sudo make install
nohup redis-server


#start node server
cd /vagrant
npm install
pm2 start pm2.json
