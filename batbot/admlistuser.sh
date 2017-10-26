#!/bin/bash
BOTDIR="$( cd "$( dirname "$0" )" && pwd )"
BATBOTCFG=$BOTDIR/.batbot
ALLUSER=$BATBOTCFG/allowed_users
ALLSUPUSER=$BATBOTCFG/allowed_superusers
USERLIST=$BATBOTCFG/user_list
COUNTER=1

if [[ $(grep -c -x "$1" $ALLSUPUSER) -eq 1 ]]; then
	for USER in $(cat $ALLUSER); do
		ID=$(grep $USER $USERLIST | awk -F":" '{printf $1}')
		NAME=$(grep $USER $USERLIST | awk -F":" '{printf $2}')
		LAST=$(grep $USER $USERLIST | awk -F":" '{printf $3}')
		USER=$(grep $USER $USERLIST | awk -F":" '{printf $4}')
		echo "Nr.$COUNTER TelegramID: $ID - Name: $NAME - Lastname: $LAST - Username: @$USER "
		COUNTER=$[COUNTER + 1]
	done
else
	echo "You are not allowed to view the user list"
fi


