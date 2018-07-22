#!/bin/sh

USER=vmadmin
GROUP=vmadmin
HOME=/home/${USER}
PROJECT=$1
SILK_VERSION=1.10.1
FPM_ROOT=/etc/php/7.0/fpm

#### DON'T EDIT ANYTHING BELOW THIS LINE ####

set -e

if [ $(id -u) -ne 0 ]; then
	echo "Must run as root."
	exit;
fi

if [ x$PROJECT = "x" ]; then
	echo "No project specified."
	exit;
fi

echo Setting up ${PROJECT}

# Setup Apache
if [ -f /etc/apache2/suexec/${USER} ]; then
	echo "cgi-bin" > /etc/apache2/suexec/${USER}
fi
echo ${HOME}/${PROJECT}/docroot >> /etc/apache2/suexec/${USER}

cp silk.conf /etc/apache2/sites-available/${PROJECT}.conf 2>&1 > ${PROJECT}-new.log
sed -i -e "s/@@USER@@/${USER}/g" /etc/apache2/sites-available/${PROJECT}.conf 2>&1 > ${PROJECT}-new.log
sed -i -e "s/@@GROUP@@/${GROUP}/g" /etc/apache2/sites-available/${PROJECT}.conf 2>&1 > ${PROJECT}-new.log
sed -i -e "s#@@HOME@@#${HOME}#g" /etc/apache2/sites-available/${PROJECT}.conf 2>&1 > ${PROJECT}-new.log
sed -i -e "s/@@PROJECT@@/${PROJECT}/g" /etc/apache2/sites-available/${PROJECT}.conf 2>&1 > ${PROJECT}-new.log

a2ensite ${PROJECT} 2>&1 > ${PROJECT}-new.log


# Don't overwrite an existing project, it may have been checked out from git already.

if [ -d ${HOME}/${PROJECT} ]; then
	echo "Project directory found, will not setup ${HOME}/${PROJECT}"
else
	## Setup Silkscreen
	mkdir -p ${HOME}/${PROJECT}/docroot ${HOME}/${PROJECT}/database ${HOME}/${PROJECT}/privat ${HOME}/${PROJECT}/config 2>&1 > ${PROJECT}-new.log
	curl -s -L -o /tmp/silkscreen.tgz https://github.com/silkscreencms/silkscreen/archive/silkscreen-${SILK_VERSION}.tar.gz 2>&1 > ${PROJECT}-new.log
	tar -C ${HOME}/${PROJECT}/docroot --strip-components=1 -xaf /tmp/silkscreen.tgz 2>&1 > ${PROJECT}-new.log
	rm /tmp/silkscreen.tgz 2>&1 > ${PROJECT}-new.log
	chown -R $USER:$GROUP ${HOME}/${PROJECT}/. 2>&1 > ${PROJECT}-new.log
	echo ">>> Don't forget to create a git project!"
fi

# Setup FPM Project Specific Pieces

if [ -f ${FPM_ROOT}/pool.d/${USER}.conf ] ; then 
	echo "PHP-FPM pool already setup."
else
	cp fpm-pool.conf ${FPM_ROOT}/pool.d/${USER}.conf 2>&1 > ${PROJECT}-new.log
	sed -i -e "s/@@USER@@/${USER}/g" ${FPM_ROOT}/pool.d/${USER}.conf 2>&1 > ${PROJECT}-new.log
	sed -i -e "s/@@GROUP@@/${GROUP}/g" ${FPM_ROOT}/pool.d/${USER}.conf 2>&1 > ${PROJECT}-new.log
	service php7.0-fpm restart 2>&1 > ${PROJECT}-new.log
fi
