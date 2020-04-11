#!/bin/bash
SCRIPTDIR=/home/pi/scripts/dnsdynamic
USERNAME=<e-mail>
PASSWORD=<password>
HOST=<dns_name>
DATE=`date +"%Y%m%d"`
LOG_FOLDER=/home/pi/scripts/dnsdynamic/logs
LOG_FILE=$LOG_FOLDER/run_$DATE.log
ALARM_FILE=$SCRIPTDIR/Alarm.txt
IP=`curl -s http://myip.dnsdynamic.org`

cd $SCRIPTDIR

if [ ! -d $LOG_FOLDER ]
then
mkdir $LOG_FOLDER
fi

if [ ! -f $LOG_FILE ]
then
touch $LOG_FILE
fi

if [ ! -f $ALARM_FILE ]
then
touch $ALARM_FILE
fi

result=`curl -s https://$USERNAME:$PASSWORD@www.dnsdynamic.org/api/?hostname=$HOST&myip=$IP`

if [ ! "$result" == "nochg" ]
then
echo "1" > $ALARM_FILE
else
echo "0" > $ALARM_FILE
fi

echo "### Scipt started at " `date +"%Y%d%m_%H%M.%N"` " ###" >> $LOG_FILE
echo "IP=$IP" >> $LOG_FILE
echo "Domain=$HOST" >> $LOG_FILE
echo "Result=$result" >> $LOG_FILE
echo "Alarm=`cat $ALARM_FILE`" >> $LOG_FILE
echo "" >> $LOG_FILE
