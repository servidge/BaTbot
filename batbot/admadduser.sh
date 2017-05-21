#!/bin/bash

ALLUSER=.batbot/allowed_users
ALLSUPUSER=.batbot/allowed_superusers

if [[ $(grep -x "$1" $ALLSUPUSER |wc -l) -eq 1 ]]; then
	if [[ $(grep -x "$2" $ALLUSER |wc -l) -eq 1 ]]; then
		echo "User $2 already present"
	else
		echo $2 >> $ALLUSER
		echo "Added User: $2"
	fi
else
	echo "You are not allowed to add users to the list"
fi
