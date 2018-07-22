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

# Reset the log file
echo ">>> Starting Install <<<" > one-time.log

echo -n "--> Updating repositories..."
apt-get update 2>&1 >> one-time.log
echo "done."

echo -n "--> Installing Apache..."
apt-get install -y apache2 apache2-suexec-custom libapache2-mod-fcgid php-fpm 2>&1 >> one-time.log
echo "done."

echo -n "--> Installing PHP..."
apt-get install -y php-gd php-json php-xml php-mbstring php-zip php-curl unzip git curl 2>&1 >> one-time.log
echo "done."

case $DATABASE in
	mariadb|mysql)
		DB_PKGS="mariadb-client mariadb-server php-mysql"
		;;
	pgsql|postgres)
		DB_PKGS="postgresql postgresql-client php-pgsql"
		;;
	sqlite|sqlite3)
		DB_PKGS="php-sqlite3"
		;;
	*)
		echo "Unknown database ${DATABASE}."
		exit;

esac

echo -n "--> Installing database $DATABASE..."
apt-get install -y ${DB_PKGS} 2>&1 >> one-time.log
echo "done."

# Configure Apache
a2enmod proxy_fcgi setenvif rewrite suexec proxy 2>&1 >> one-time.log
a2enconf php7.0-fpm 2>&1 >> one-time.log

service apache2 restart 2>&1 >> one-time.log

echo "Ready for a new project.  Run sudo ./new-project.sh <project>"
