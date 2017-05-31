#!/bin/bash
BOTDIR=/opt/bash/bot
BATBOTCFG=$BOTDIR/.batbot
USERLIST=$BATBOTCFG/user_list

#USER="$@"
#ID=$(echo $USER | awk -F":" '{printf $1}')
#NAME=$(echo $USER | awk -F":" '{printf $2}')
if [[ $@ =~ (.*)":"(.*) ]]; then
	ID=${BASH_REMATCH[1]}
	NAME=${BASH_REMATCH[2]}
	#echo $ID1 $NAME1
	if [[ $(grep -c ^$ID: $USERLIST) == 0 ]]; then
		echo "$ID:$NAME" >> $USERLIST
	fi
fi
