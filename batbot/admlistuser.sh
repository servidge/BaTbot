#!/bin/bash

ALLUSER=.batbot/allowed_users
ALLSUPUSER=.batbot/allowed_superusers
USERLIST=.batbot/user_list

if [[ $(grep -c -x "$1" $ALLSUPUSER) -eq 1 ]]; then
	for USER in $(cat $ALLUSER); do
		ID=$(grep $USER $USERLIST | awk -F":" '{printf $1}')
		NAME=$(grep $USER $USERLIST | awk -F":" '{printf $2}')
		echo "TelegramID: $ID - User: $NAME"
	done
else
	echo "You are not allowed to view the user list"
fi
