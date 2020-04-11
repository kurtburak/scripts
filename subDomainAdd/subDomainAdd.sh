#!/bin/sh
SCRIPT_DIR='.'
APACHE_SITES_DIR='/etc/httpd/vhost.d'
INPUT_FILE=$SCRIPT_DIR/inputFile.txt
SAMPLE_SITE_FILE=$SCRIPT_DIR/default.conf
BACKUP_DIR=$SCRIPT_DIR/temp
RUN_TIME=`date +"%Y%m%d"`
# DATA=`cat $SAMPLE_SITE_FILE`
DOMAIN_NAME=
SITE_DIR=
USER_NAME=$1
USE_DEFAULT_SUB_DIR=1
DEFAULT_SUB_DIR="/var/www/vhosts"

cd $SCRIPT_DIR

function backupSites {
	if [ ! -d "$BACKUP_DIR/bb_backup_$RUN_TIME" ]; then
		mkdir $BACKUP_DIR/bb_backup_$RUN_TIME
	fi
        cp -Rf $APACHE_SITES_DIR $BACKUP_DIR/bb_backup_$RUN_TIME/
}


function addSite2Apache {
        site=$APACHE_SITES_DIR/$DOMAIN_NAME'.conf'
        if [ -f $site ];then
                echo "$DOMAIN_NAME is already exist! Skipping..."
        else
                if [ -d $SITE_DIR ];then
                        echo "$SITE_DIR already exist! Skipping..."
                else
                        mkdir -p $SITE_DIR
                        touch $site
                        echo "<VirtualHost *:80>" > $site
                        echo "        ServerName $DOMAIN_NAME" >> $site
                        echo "        ServerAlias www.$DOMAIN_NAME" >> $site
                        echo "        DocumentRoot $SITE_DIR" >> $site
			echo "       <Directory $SITE_DIR>" >> $site
			echo                 Options Indexes FollowSymLinks MultiViews >> $site
			echo "                AllowOverride All" >> $site
			echo "        </Directory>" >> $site
                        echo "</VirtualHost>" >> $site
                        echo "127.0.0.1 $DOMAIN_NAME" >> /etc/hosts
#                        a2ensite $DOMAIN_NAME
                        if [ "$?" -eq "0" ];then echo "Domain: $DOMAIN_NAME, root: $SITE_DIR, Status: OK!";fi
			addTestPage
                fi
        fi
}

function addTestPage {
	if [ ! -f "$SITE_DIR/index.html" ]; then
		echo "<html><body><br><br>TEST OK</body></html>" > $SITE_DIR/index.html
	fi
}


# sudo run
if [[ $UID != 0 ]]; then
    echo "Please start the script as root or sudo!"
    exit 1
fi

# param control
#if [[ $# < 1 ]]; then
#	echo "Missing parameter!"
#	echo "Usage: bash $0 USER_NAME"
#	exit 1
#fi

# httpd vhost control
param="Include vhost.d/*.conf"
a_httpdConf=/etc/httpd/conf/httpd.conf
a_conf=`grep "^Include" /etc/httpd/conf/httpd.conf|grep "vhost.d"|grep "conf"`
if [ "$a_conf" == "" ]; then
	echo $param >> /etc/httpd/conf/httpd.conf
fi

# mkdir tmo
if [ ! -d "$SCRIPT_DIR/temp" ]; then mkdir $SCRIPT_DIR/temp; fi
# mkdir vhost.d
if [ ! -d "$APACHE_SITES_DIR" ]; then mkdir $APACHE_SITES_DIR; fi

# backup first
backupSites

# adding part
numOfLines=`cat $INPUT_FILE | wc -l`
for (( i=1; i<=$numOfLines; i++ ));do
        theLine=`sed -n "${i}p" $INPUT_FILE`
        DOMAIN_NAME=`echo $theLine|awk '{print$1}'`
        if [ "$USE_DEFAULT_SUB_DIR" == "1" ]; then 
		SITE_DIR=$DEFAULT_SUB_DIR/$DOMAIN_NAME
	else
		SITE_DIR=`echo $theLine|awk '{print$2}'`
	fi
        addSite2Apache
# printf "Press any key to cont..."; read -n 1 asd
done

# restart service
#service apache2 reload
service httpd restart

