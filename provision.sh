#!/usr/bin/env bash
###############Linux stuff#################### 
# Update and upgrade
sudo apt-get update
sudo apt-get -y upgrade

# Install Apache, MySQL, PHP, and Git
sudo apt-get install -y apache2 mysql-server git
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y curl
sudo apt-get install -y php8.1
sudo apt-get install -y php8.1-common php8.1-mysql php8.1-xml php8.1-xmlrpc php8.1-curl php8.1-gd php8.1-imagick php8.1-cli php8.1-dev php8.1-imap php8.1-mbstring php8.1-opcache php8.1-soap php8.1-zip php8.1-redis php8.1-intl
sudo apt-get -y install php-xml
sudo apt-get -y install php-mysql
sudo apt-get -y install php-curl php-zip
sudo apt-get -y install libapache2-mod-php
sudo service apache2 restart

# Download and install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

EXPECTED_HASH="e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02"
ACTUAL_HASH=$(sha384sum composer-setup.php | awk '{print $1}')

if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
    echo "Composer installer checksum verification failed. Aborting installation."
    exit 1
fi
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"
sudo chmod +x /usr/local/bin/composer
composer --version

# Edit php.ini to update the include_path
PHP_INI_PATH=$(php --ini | grep "Loaded Configuration File" | sed -e "s|.*:\s*||")
PHP_INCLUDE_PATH="/var/www/html/my-app/vendor" 

# Check if the php.ini path is found
if [ -f "$PHP_INI_PATH" ]; then
    # Update the include_path in php.ini
    sudo sed -i "s|;include_path = \".:/usr/share/php\"|include_path = \".:/usr/share/php:$PHP_INCLUDE_PATH\"|" "$PHP_INI_PATH"

    # Restart the web server (Apache in this case)
    sudo service apache2 restart
    echo "Updated include_path in $PHP_INI_PATH"
else
    echo "PHP configuration file not found. Please update include_path manually."
fi

# Configure MySQL (You should set your own password here)
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo mysqladmin -uroot -proot create devops

# Create the directory for your PHP application
sudo mkdir -p /var/www/html/my-app
sudo chown -R $USER:$USER /var/www/html/my-app

####setting up git configur
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

# Clone the PHP application from GitHub (Specify the correct repository URL)
git clone https://github.com/laravel/laravel.git /var/www/html/my-app
cd /var/www/html/my-app
rm -f public/index.html

# Install Composer dependencies
composer install

# Copy the environment file
cp .env.example .env

# Set file permissions for the .env file
chmod 644 /var/www/html/my-app/.env

# Generate application key
php artisan key:generate

# Set permissions for Laravel storage
sudo chmod -R 775 storage

# Clear cache and config
php artisan cache:clear
php artisan config:clear

# Start the Laravel development server
php artisan serve --host=0.0.0.0 --port=8000 &

# Define the virtual host configuration
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin admin@my-app
    ServerName local-host
    DocumentRoot /var/www/html/my-app/public
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html/my-app/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)

# Create the virtual host configuration file
echo "$VHOST" | sudo tee /etc/apache2/sites-available/my-app.conf

# Enable the virtual host
sudo a2ensite my-app

# Reload Apache to apply the new configuration
sudo systemctl reload apache2

# Disable the default Apache configuration
sudo a2dissite 000-default.conf

# Reload Apache to apply the changes
sudo systemctl reload apache2

# Output a message indicating the completion of the script
echo "LAMP stack and PHP application deployment completed."
