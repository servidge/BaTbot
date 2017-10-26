#!/bin/bash
BOTDIR="$( cd "$( dirname "$0" )" && pwd )"
BATBOTCFG=$BOTDIR/.batbot
ALLUSER=$BATBOTCFG/allowed_users
ALLSUPUSER=$BATBOTCFG/allowed_superusers

if [[ $(grep -c -x "$1" $ALLSUPUSER) -eq 1 ]]; then
	if [[ $(grep -c -x "$2" $ALLUSER) -eq 1 ]]; then
		echo "User $2 already present"
	else
		echo $2 >> $ALLUSER
		echo "Added User: $2"
	fi
else
	echo "You are not allowed to add users to the list"
fi
