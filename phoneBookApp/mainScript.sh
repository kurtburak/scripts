#!/bin/bash

### VARIABLES ###
SCRIPT_DIR=.
BOOK_DIR=$SCRIPT_DIR/phoneBooks
BOOK=
UCLASS="Student User"
USERDB=$SCRIPT_DIR/passwd_sample.txt
LAST_NAME=$1
FIRST_NAME=$2
PHONE_NUM=$3

### FUNCTIONS ###
function hello {
        echo "############################"
        echo "## Phone Book Application ##"
        echo "############################"
        echo ""
}

function checkBook {
        file=$1

	if [ ! -f $file ];then
		echo "File not found!"
                echo "Script aborted!"
		exit 0
	fi

        size=`du -b $file|awk '{print $1}'`

        if [ "$size" == "0" ];then
                echo "ERROR: Phone book file is not a valid regular file!"
                echo "Script aborted!"
                exit 0
        fi

        for i in `cat $file|grep -v \#`;do
                cond1="${i//[^:]}"
                cond2=${#cond1}
                if [ "$cond2" != "2" ];then
                echo "ERROR: File does not contain a configuration consistent with a phone book"
                echo "Script aborted!"
                exit 0
                fi
        done
}

function checkExit {
	if [ "$1" == "X" ] || [ "$1" == "x" ];then
		echo "Exit signal \"X\" detected!"
		echo "Program closed!"
		exit 0
	fi
}

function checkUser {
	if [ "$1" != "" ];then
		userDB=/etc/passwd
	else
		userDB=$USERDB
	fi

	cond=`cat $userDB|grep -i "$USER"|grep -i "$UCLASS"`

	if [ "$cond" == "" ];then
		echo "0"
	else
		echo "1"
	fi
}

function addContact {
	perm=`checkUser`
	if [ "$perm" == "0" ]; then
	echo "Permision denied for user \"$USER\"!"
	else

	if [ "$FIRST_NAME" == "" ];then
		printf "Enter First Name: "
		read FIRST_NAME
	fi

	printf "Enter Phone Number: "
        read -r a_PHONE_NUM

	a_fullInfo=$LAST_NAME:$FIRST_NAME:$a_PHONE_NUM
	
	echo $a_fullInfo >> $fullBook
	echo "Contact has been added to phone book."
	fi
}

function delContact {
perm=`checkUser`
        if [ "$perm" == "0" ]; then
        echo "Permision denied for user \"$USER\"!"
        else

	if [ "$FIRST_NAME" == "" ];then
                printf "Enter First Name: "
                read FIRST_NAME
        fi

	d_rec=`cat $fullBook|grep -i "$LAST_NAME"|grep -i "$FIRST_NAME"|grep -v \#`
	if [ "$d_rec" != "" ];then
		d_recCount=`cat $fullBook|grep -i "$LAST_NAME"|grep -i "$FIRST_NAME"|grep -v \# |wc -l`
		d_lines=`cat -n $fullBook|grep "$d_rec"|awk '{print $1}'`
	
	if [ "$d_recCount" == "1" ];then
		sed "$d_lines"d $fullBook > $BOOK_DIR/temp
		mv $BOOK_DIR/temp $fullBook
		echo "Record deleted!"
	elif (( $d_recCount > 1 )); then
		echo "Following $d_recCount records are found."
		echo $d_rec
		printf "Do you want to delete all? [y/n]: "
		read d_answer
		if [ "$d_answer" == "y" ] || [ "$d_answer" == "Y" ]; then
			for i in `cat $fullBook|grep -i "$LAST_NAME"|grep -i "$FIRST_NAME"|grep -v \#`; do
				grep -iv $i $fullBook > $BOOK_DIR/temp
				mv $BOOK_DIR/temp $fullBook
			done
			echo "Record deleted!"
		else
			echo "No record deleted!"
		fi
	fi
	else
		echo "No record found!"
	fi
fi
}

function modContact {
perm=`checkUser`
        if [ "$perm" == "0" ]; then
        echo "Permision denied for user \"$USER\"!"
        else

	if [ "$FIRST_NAME" == "" ];then
                printf "Enter First Name: "
                read FIRST_NAME
        fi

	d_rec=`cat $fullBook|grep -i "$LAST_NAME"|grep -i "$FIRST_NAME"|grep -v \#`
        if [ "$d_rec" != "" ];then
                d_recCount=`cat $fullBook|grep -i "$LAST_NAME"|grep -i "$FIRST_NAME"|grep -v \# |wc -l`
                d_lines=`cat -n $fullBook|grep "$d_rec"|awk '{print $1}'`
	
	if [ "$d_recCount" == "1" ]; then

	  printf "Enter new Last Name: "
          read n_LAST_NAME

          printf "Enter new First Name: "
          read n_FIRST_NAME

          printf "Enter new Phone Number: "
          read n_PHONE_NUM

          newContact=$n_LAST_NAME:$n_FIRST_NAME:$n_PHONE_NUM

          delContact > /dev/null

          echo $newContact >> $fullBook
	  echo "Contact has been modified."
	
	fi

	if (( $d_recCount > 1 )); then
		echo "More than one record is found!"
		echo "Please run program with both Last Name and First Name parameter"
		echo "or delete all duplicated using (D)elete option in the menu. "
	fi
	else
                echo "No record found!"
	fi
fi
}

function dispAll {
	d_rec=`cat $fullBook|grep -v \#`
        if [ "$d_rec" != "" ];then
                d_recCount=`cat $fullBook|grep -v \# |wc -l`
	echo "Followng records are found."
        i_count=1
        for i in `cat $fullBook |grep -v \# | sort`
        do
                echo "$i_count. `echo $i | tr ':' ' '`"
                let i_count=$i_count+1
        done
	
	else
		echo "No record found!"

	fi
}

function dispContact {

	d_rec=`cat $fullBook|grep -i "$LAST_NAME"|grep -i "$FIRST_NAME"|grep -v \#`
        if [ "$d_rec" != "" ];then
                d_recCount=`cat $fullBook|grep -i "$LAST_NAME"|grep -i "$FIRST_NAME"|grep -v \# |wc -l`
                d_lines=`cat -n $fullBook|grep "$d_rec"|awk '{print $1}'`


	echo "Followng records are found."
	i_count=1
	for i in `cat $fullBook | grep -i "$LAST_NAME" | grep -i "$FIRST_NAME" |grep -v \# | sort`
	do
		echo "$i_count. `echo $i | tr ':' ' '`"
		let i_count=$i_count+1
	done

	else
                echo "No record found!"

        fi
}

function startMenu {
	cMenu=0
	while true; do
		if [ "$cMenu" != "0" ];then
			echo ""
			echo "Press Enter to continue..."
			read
		fi
		echo ""
		echo "Choose one of the following options"
		echo "(A) - Add an entry to the phone book"
		echo "(D) - Delete an entry from the phone book"
		echo "(M) - Modify an entry in the phone book"
		echo "(I) - Display an entry in the phone book"
		echo "(P) - Display all entries in the phone book"
		echo "(X) - Exit the program"
		printf "Option: "
		read option

		if [ "$option" == "A" ] || [ "$option" == "a" ];then
			addContact
		

		elif [ "$option" == "D" ] || [ "$option" == "d" ];then
			delContact
		

		elif [ "$option" == "M" ] || [ "$option" == "m" ];then
			modContact
		

		elif [ "$option" == "I" ] || [ "$option" == "i" ];then
			dispContact
		

		elif [ "$option" == "P" ] || [ "$option" == "p" ];then
			dispAll
		

		elif [ "$option" == "X" ] || [ "$option" == "x" ];then
			checkExit $option
		
		else
			echo "Unkown option! Try again."
		fi

		let cMenu=$cMenu+1

	done
}

# welcome screen
hello

# start argument control
if (( $# < 1 ))
then
        echo "ERROR: Script must be run with at least one argument which is last name!"
        echo "Usage 1: $0 LAST_NAME"
        echo "Usage 2: $0 LAST_NAME FIRST_NAME"
        echo ""
        exit 0

elif  (( $# > 2 ))
then
        echo "ERROR: You can run script with max. two arguments which are last name and first name!"
        echo "Usage 1: $0 LAST_NAME"
        echo "Usage 2: $0 LAST_NAME FIRST_NAME"
        echo ""
        exit 0

elif [ "$#" = "1" ]
then
        echo "WARNING: Only one argument detected."
        echo "More than one entry might be returned from the phone book."
        echo ""
fi

# phone book directory and file controls
printf "Enter the phone book directory (Blank for $BOOK_DIR): "
read t_BOOK_DIR
checkExit $t_BOOK_DIR

if [ ! -d $t_BOOK_DIR ];then
	echo "Folder not found!"
        echo "Script aborted!"
	exit 0
fi

if [ "$t_BOOK_DIR" != "" ];then
        BOOK_DIR=`echo $t_BOOK_DIR`
fi

bookCount=`ls $BOOK_DIR|wc -l`
if [ "$bookCount" == "1" ];then
        BOOK=`ls $BOOK_DIR`
else
  echo "$bookCount file(s) found in $BOOK_DIR"
counter=1
  for i in `ls $BOOK_DIR`;do
        echo "$counter. $i"
        let counter=counter+1
  done
printf "Enter phone book file manually: "
read BOOK
checkExit $BOOK
fi
fullBook=$BOOK_DIR/$BOOK

# check regularity of phone book
checkBook $fullBook

# start the menu interface
startMenu
