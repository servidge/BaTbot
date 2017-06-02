#!/bin/bash
BOTDIR=/opt/bash/bot
BATBOTCFG=$BOTDIR/.batbot
ALLUSER=$BATBOTCFG/allowed_users
ALLSUPUSER=$BATBOTCFG/allowed_superusers
USERLIST=$BATBOTCFG/user_list

if [[ $(grep -c -x "$1" $ALLSUPUSER) -eq 1 ]]; then
	for USER in $(cat $ALLUSER); do
		ID=$(grep $USER $USERLIST | awk -F":" '{printf $1}')
		NAME=$(grep $USER $USERLIST | awk -F":" '{printf $2}')
		LAST=$(grep $USER $USERLIST | awk -F":" '{printf $3}')
		echo "TelegramID: $ID - User: $NAME - Lastname: $LAST"
	done
else
	echo "You are not allowed to view the user list"
fi
