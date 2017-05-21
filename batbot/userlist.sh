#!/bin/bash

#USER="$@"
USERLIST=.batbot/user_list

#ID=$(echo $USER | awk -F":" '{printf $1}')
#NAME=$(echo $USER | awk -F":" '{printf $2}')
if [[ $@ =~ (.*)":"(.*) ]]; then
	ID=${BASH_REMATCH[1]}
	NAME=${BASH_REMATCH[2]}
	#echo $ID1 $NAME1
	if [[ $(grep $ID $USERLIST) == "" ]]; then
		echo "$ID:$NAME" >> $USERLIST
	fi
fi
