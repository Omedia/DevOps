#!/bin/bash

cd /opt

DN="$1"
EMAIL="$2"
SERVER="$3"
WEBROOT="$4"
shift 4

#wget https://dl.eff.org/certbot-auto && chmod a+x certbot-auto

#./certbot-auto certonly --webroot -w /var/www/html/ -d $DN -d www.$DN -m $EMAIL

if [ -z $DN  ]
then
echo "Syntax is: ./cert.sh DomainName Email Server(nginx/apache) Webroot"
exit
fi

if [ $SERVER == "nginx" ]
then
  cd /etc/nginx/sites-available
  echo "server {
    listen 80;

    server_name $DN www.$DN;

    rewrite ^ https://$DN\$request_uri? permanent;
    rewrite ^ https://www.$DN\$request_uri? permanent;
    }

server {
    listen 443 ssl;

    ssl_certificate /etc/letsencrypt/live/$DN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DN/privkey.pem;
    ssl_stapling on;

    server_name $DN www.$DN;

    root /var/www/$WEBROOT;

    location / {
        try_files \$uri /index.php?\$args;
}

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}" > $DN.conf

sudo ln -s $DN.conf ../sites-enabled/

sudo service nginx reload
fi

if [ $SERVER == "apache" ]
then
cd /etc/apache2/sites-available
sudo a2dissite $DN.conf
sudo a2enmod ssl
sudo service apache2 reload
sudo service apache2 stop
sudo rm $DN.conf
sudo rm ../sites-enabled/$DN.conf
sudo service apache2 start
echo "<VirtualHost *:80>
    ServerName $DN
    ServerAlias www.$DN
    DocumentRoot /var/www/$WEBROOT
<Directory /var/www/$WEBROOT/>
RewriteEngine on
RewriteBase /
RewriteCond %{HTTP_HOST} ^$DN
RewriteRule (.*) http://www.$DN/\$1 [R=301,L]
</Directory>
</VirtualHost>

<VirtualHost _default_:443>
        <Directory /var/www/$WEBROOT/>
        Options Indexes FollowSymLinks Multiviews
        AllowOverride All
        Order allow,deny
        allow from all
        </Directory>
        ServerName $DN
        ServerAlias www.$DN
        DocumentRoot /var/www/$WEBROOT
        #SSLEngine On
        #SSLCertificateFile "/etc/letsencrypt/live/$DN/cert.pem"
        #SSLCertificateKeyFile "/etc/letsencrypt/live/$DN/privkey.pem"
        #SSLCertificateChainFile "/etc/letsencrypt/live/$DN/chain.pem"
</VirtualHost>" > $DN.conf


sudo a2ensite $DN.conf

sudo service apache2 reload
fi
