#!/bin/bash
SCRIPTDIR=/home/pi/scripts/twitter/bbACCOUNTbb
DATE=`date +"%Y%m%d"`
LOG_FOLDER=/home/pi/scripts/twitter/logs
LOG_FILE=$LOG_FOLDER/run_$DATE.log
ALARM_FILE=$SCRIPTDIR/Alarm.txt
LAST_RUN=$SCRIPTDIR/lastRun.txt
WORD_FILE=$SCRIPTDIR/words.txt
HT_FILE=$SCRIPTDIR/listTrendsHT.txt
IM_FOLDER=/mnt/data/bbACCOUNTbb/images
TWIT_SCRIPT=$SCRIPTDIR/bbTWPOSTbb
TWIT_SCRIPT_IM=$SCRIPTDIR/bbTWPOSTIMbb
#HT_SCRIPT=$SCRIPTDIR/trends.sh
MIN=0
RANGE=5
MIN_RUN_FREQ=bbMINRUNbb		# in minutes

if [ ! -f $LAST_RUN ]
then
echo "0" > $LAST_RUN
fi

lastRun=`cat $LAST_RUN`

let timeInterval=$(date +%s)-$lastRun
let timeInterval=timeInterval/60

# Check last run
if [[ $timeInterval -lt $MIN_RUN_FREQ ]]
then
echo "### EXIT! $0 - Last running time is less then $MIN_RUN_FREQ " >> $LOG_FILE
exit 0
fi


# Usual controls
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


if [[ $# -ne 0 ]]
then
MIN=$1
fi

# Get top hashtag
# bash $HT_SCRIPT
#hashTag=`head -3 $HT_FILE`
hashTag=
echo "HashTag: $hashTag" >> $LOG_FILE

# Calculate sleep time
rand=`echo $RANDOM`
let rand=$rand%$RANGE+$MIN
let rand=$rand*60

echo "### $0 Scipt started at " `date +"%Y%d%m_%H%M.%N"` " ###" >> $LOG_FILE
echo "Sleep: $rand sec" >> $LOG_FILE

sleep $rand

# Get word list
totalCountWords=`wc -l ./words.txt|awk '{print $1}'`
# Select random word
lineWord=`echo $RANDOM`
let lineWord=$lineWord%$totalCountWords+1
theWord=`sed -n "$lineWord{p;q}" $WORD_FILE`
#theWord='Check It Out!!!'
#theWord=''
echo "WORD: $theWord" >> $LOG_FILE

# Select and Count Images
imList=($(ls $IM_FOLDER))
numOfIm=`ls $IM_FOLDER | wc -l`
let ranIm=$RANDOM%$numOfIm+1
theImg=`echo ${imList[$ranIm]}`
theImg=$IM_FOLDER/$theImg

echo "IMG: $theImg" >> $LOG_FILE

#let imDec=$RANDOM%3
imDec=0
# RUN Twit Script
if [[ $imDec -eq 0 ]]
then
 pyStatus=`/usr/bin/python $TWIT_SCRIPT_IM "$theWord $hashTag" "$theImg"`
else
 pyStatus=`/usr/bin/python $TWIT_SCRIPT "$theWord $hashTag"`
fi

if [ "$pyStatus" == "" ]
then
 echo "Twit Status: OK!" >> $LOG_FILE
 echo "Twit Status: $pyStatus" >> $LOG_FILE
 date +%s > $LAST_RUN
 echo "0" > $ALARM_FILE
else
 echo "Twit Status: $pyStatus" >> $LOG_FILE
 echo "1" > $ALARM_FILE
fi

echo "" >> $LOG_FILE
