#!/bin/bash
#
# SimpleMenu.sh - Only SomeWhat Useful ;)
#
# 2008 - Mike Golvach - eggi@comcast.net
# Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License
########################################################################################

SCRIPT_DIR=.
ACCOUNT=
MAIN_TW_DIR=/home/pi/scripts/twitter
NEW_ACCOUNT_DIR=$MAIN_TW_DIR/$ACCOUNT
DEFAULT_TW_POST=$SCRIPT_DIR/defaultTWPost.py
DEFAULT_TW_POST_IM=$SCRIPT_DIR/defaultTWPost_IM.py
DEFAULT_MAIN_SCRIPT=$SCRIPT_DIR/defaultScript.sh
DEFAULT_IMG_DIR="/mnt/data/im_tw/$ACCOUNT/images"
CRON_FILE=$MAIN_TW_DIR/twitScriptList.txt

function header {
	headCount=4
        tput cup 0 0 ; echo -n "##################################################"
        tput cup 1 0 ; echo -n "#           Twitter Account Manager              #"
        tput cup 2 0 ; echo -n "#               Burak Kurt - 2015                #"
        tput cup 3 0 ; echo -n "##################################################"
}

function dispMen {
	menuCount=4
	tput cup $(($headCount)) 0 ;   echo "# 1. Create Auto Twitter Account                 #"
	tput cup $(($headCount+1)) 0 ; echo "# 2. Display Installed Twitter Accounts          #"
	tput cup $(($headCount+2)) 0 ; echo "# 3. Edit Account                                #"
	tput cup $(($headCount+3)) 0 ; echo "# 9. QUIT                                        #"

}

function footer {
# $1 line where footer starts
	footCount=2
#        tput cup $((headCount+$menuCount)) 0 ; echo -n "Valid keys: k (up), j (down)"
#        tput cup $(($headCount+$menuCount+1)) 13 ; echo -n "h (left), l (right)"
#        tput cup $(($headCount+$menuCount+2)) 13 ; echo -n "q: quit"
        tput cup $(($headCount+$menuCount)) 0 ; echo -n "##################################################"
        tput cup $(($headCount+$menuCount+1))  0 ; echo -n "=> Command: "
#        tput cup 0 0 ; echo -n " 5. Quit                    "
}

function sudoTest {
	if [[ $UID != 0 ]]; then
	    echo "Please start the script as root or sudo!"
	    exit 1
	fi
}

function defineVARs {
	echo $1
	echo $ACCOUNT
	NEW_ACCOUNT_DIR=$MAIN_TW_DIR/$1
	DEFAULT_IMG_DIR="/mnt/data/im_tw/$1/images"
}

function createFolders {
	mkdir -p $NEW_ACCOUNT_DIR
	mkdir -p $DEFAULT_IMG_DIR
}

function createPostScipts {
	cp $DEFAULT_TW_POST $NEW_ACCOUNT_DIR/${ACCOUNT}T.py_tmp
	sed -i "s/bbCONSKEYbb/${CONSUMER_KEY}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}T.py_tmp
	sed -i "s/bbCONSSECbb/${CONSUMER_SECRET}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}T.py_tmp
	sed -i "s/bbACCTOKbb/${ACCESS_KEY}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}T.py_tmp
	sed -i "s/bbACCTOKSECbb/${ACCESS_SECRET}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}T.py_tmp
	mv $NEW_ACCOUNT_DIR/${ACCOUNT}T.py_tmp $NEW_ACCOUNT_DIR/${ACCOUNT}T.py

	cp $DEFAULT_TW_POST_IM $NEW_ACCOUNT_DIR/${ACCOUNT}T_IMG.py_tmp
	sed -i "s/bbCONSKEYbb/${CONSUMER_KEY}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}T_IMG.py_tmp
	sed -i "s/bbCONSSECbb/${CONSUMER_SECRET}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}T_IMG.py_tmp
	sed -i "s/bbACCTOKbb/${ACCESS_KEY}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}T_IMG.py_tmp
	sed -i "s/bbACCTOKSECbb/${ACCESS_SECRET}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}T_IMG.py_tmp
	mv $NEW_ACCOUNT_DIR/${ACCOUNT}T_IMG.py_tmp $NEW_ACCOUNT_DIR/${ACCOUNT}T_IMG.py

	touch $NEW_ACCOUNT_DIR/words.txt
}

function createMainScript {
	cp $DEFAULT_MAIN_SCRIPT $NEW_ACCOUNT_DIR/${ACCOUNT}.sh_tmp
	sed -i "s/bbACCOUNTbb/${ACCOUNT}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}.sh_tmp
#	sed -i "s/bbIMFOLDERbb/${DEFAULT_IMG_DIR}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}.sh_tmp
	sed -i "s/bbTWPOSTbb/${ACCOUNT}T.py/g" $NEW_ACCOUNT_DIR/${ACCOUNT}.sh_tmp
	sed -i "s/bbTWPOSTIMbb/${ACCOUNT}T_IMG.py/g" $NEW_ACCOUNT_DIR/${ACCOUNT}.sh_tmp
	sed -i "s/bbMINRUNbb/${MIN_RUN_FREQ}/g" $NEW_ACCOUNT_DIR/${ACCOUNT}.sh_tmp
	mv $NEW_ACCOUNT_DIR/${ACCOUNT}.sh_tmp $NEW_ACCOUNT_DIR/${ACCOUNT}.sh
}



function getCup {
	# based on a script from http://invisible-island.net/xterm/xterm.faq.html
	oldstty=$(stty -g)
	stty raw -echo min 0
	# on my system, the following line can be replaced by the line below it
	echo -en "\033[6n" > /dev/tty
	# tput u7 > /dev/tty    # when TERM=xterm (and relatives)
	IFS=';' read -r -d R -a pos
	stty $oldstty
	# change from one-based to zero based so they work with: tput cup $row $col
	rowCup=$((${pos[0]:2} - 1))    # strip off the esc-[
	colCup=$((${pos[1]} - 1))
tput cup 35 5
echo "ROW:$rowCup COL:$colCup"
}


# before initialize
#tput civis

sudoTest

loop=0
while :
do
        clear
	let loop=loop+1

# start header
	tput cup 0 0
	header
	dispMen
	footer

#	if [ $loop == 1 ];then
#		tput cup $(($headCount+$listCount+menuCount - 1)) 10
#		tput sc
#	else
#		tput rc
#	fi


read -n 1 move
case "$move" in
	1)	# create account
		clear
		tput cup 0 0
		header
		echo ""

		echo -n "# (1/6). AccountName (withNoSpace): "; read -e ACCOUNT
		echo -n "# (2/6). Consumer Key: "; read -e CONSUMER_KEY
		echo -n "# (3/6). Comsumer Secret: "; read -e CONSUMER_SECRET
		echo -n "# (4/6). Access Key: "; read -e ACCESS_KEY
		echo -n "# (5/6). Access Secret: "; read -e ACCESS_SECRET
		echo -n "# (6/6). Minimum Running Frequecy (sn): "; read -e MIN_RUN_FREQ

		defineVARs $ACCOUNT
		
		echo -n "INFO: Folder are being created... "
		createFolders
		if [ "$?" -eq "0" ]; then
                        echo "OK!"
                else
                        echo "Failed!"
                        exit 1
                fi

		echo -n "INFO: Auto Twit Post Scripts are being created... "
		
		createPostScipts
		if [ "$?" -eq "0" ]; then
			echo "OK!"
		else
			echo "Failed!"
			exit 1
		fi
		
		echo -n "INFO: Main Twit Script is being created... "
		createMainScript
		if [ "$?" -eq "0" ]; then
			echo "OK!"
		else
			echo "Failed!"
			exit 1
		fi
		
		echo -n "=> Add New Account To Auto Twit List wit period $MIN_RUN_FREQ sn ? (yes/no): "; read -n 1 answer
		if [ "$answer" == "y" ]; then
			echo "./$ACCOUNT/$ACCOUNT.sh" >> $CRON_FILE
			echo "INFO: $ACCOUNT added!"
		else
			echo "INFO: Not Added!"
		fi

		echo -n "INFO: Permissions are bing set... "
		chown -R pi:pi $NEW_ACCOUNT_DIR
		chmof -R 755 $NEW_ACCOUNT_DIR
		if [ "$?" -eq "0" ]; then
                        echo "OK!"
                else
                        echo "Failed!"
                        exit 1
                fi

		;;
	3)	# down
		;;
	4)	# left
		;;
	5)	# right
		;;
	q|Q)	# quit
		exit 1
		
esac
done
