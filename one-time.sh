#!/bin/sh

DATABASE=mysql

#### DON'T EDIT ANYTHING BELOW THIS LINE ####

if [ $(id -u) -ne 0 ]; then
	echo "Must run as root."
	exit;
fi

apt-get update
apt-get install -y apache2 apache2-suexec-custom libapache2-mod-fcgid php-fpm
apt-get install -y php-gd php-json php-xml php-mbstring php-zip php-curl unzip git

case $DATABASE in
	mariadb|mysql)
		DB_PKGS="mariadb-client mariadb-server php-mysql"
	;;
	pgsql|postgres)
		DB_PKGS="postgresql-server postgresql-client php-pgsql"
		DB_DRIVER="database_pgsql"
	;;
	sqlite|sqlite3)
		DB_PKGS="php-sqlite3"
		DB_DRIVER="database_sqlite"

esac

apt-get install -y $DB_PKGS

if [ x$DRIVER != "x" ]; then 
	# Fetch the latest drivers
	echo "Drivers"
fi

# Configure Apache
a2enmod proxy_fcgi setenvif rewrite suexec proxy
a2enconf php7.0-fpm

service apache2 restart
