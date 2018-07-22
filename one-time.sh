#!/bin/sh

DATABASE=$1

#### DON'T EDIT ANYTHING BELOW THIS LINE ####

if [ $(id -u) -ne 0 ]; then
	echo "Must run as root."
	exit;
fi

if [ x$DATABASE = "x" ]; then
	echo "usage: $0 <DATABASE>"
	exit;
fi

echo -n "--> Updating repositories..."
apt-get update -qq
echo "done."

echo -n "--> Installing Apache..."
apt-get install -qq -y apache2 apache2-suexec-custom libapache2-mod-fcgid php-fpm > /dev/null
echo "done."

echo -n "--> Installing PHP..."
apt-get install -qq -y php-gd php-json php-xml php-mbstring php-zip php-curl unzip git curl > /dev/null
echo "done."

case $DATABASE in
	mariadb|mysql)
		DB_PKGS="mariadb-client mariadb-server php-mysql"
	;;
	pgsql|postgres)
		DB_PKGS="postgresql postgresql-client php-pgsql"
		DB_DRIVER="database_pgsql"
	;;
	sqlite|sqlite3)
		DB_PKGS="php-sqlite3"
		DB_DRIVER="database_sqlite"

esac

echo -n "--> Installing database $DATABASE..."
apt-get install -qq -y $DB_PKGS > /dev/null
echo "done."

if [ x$DRIVER != "x" ]; then 
	# Fetch the latest drivers
	echo "Drivers"
fi

# Configure Apache
a2enmod -q proxy_fcgi setenvif rewrite suexec proxy > /dev/null
a2enconf -q php7.0-fpm > /dev/null

service apache2 restart

echo "Ready for a new project.  Run sudo ./new-project.sh <project>"
