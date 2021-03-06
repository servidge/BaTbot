#!/bin/bash
BOTDIR="$( cd "$( dirname "$0" )" && pwd )"
BATBOTCFG=$BOTDIR/.batbot
ALLUSER=$BATBOTCFG/allowed_users
ALLSUPUSER=$BATBOTCFG/allowed_superusers

if [[ $(grep -c -x "$1" $ALLSUPUSER) -eq 1 ]]; then
	if [[ $(grep -c -x "$2" $ALLUSER) -eq 1 ]]; then
		grep -vx "$2" $ALLUSER > $ALLUSER.temp && mv $ALLUSER.temp $ALLUSER
		echo "Removed user: $2"
	else
		echo "User $2 not in list"
	fi
else
	echo "You are not allowed to delete users from list"
fi
