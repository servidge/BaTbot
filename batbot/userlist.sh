#!/bin/bash
BOTDIR="$( cd "$( dirname "$0" )" && pwd )"
BATBOTCFG=$BOTDIR/.batbot
USERLIST=$BATBOTCFG/user_list

#USER="$@"
#ID=$(echo $USER | awk -F":" '{printf $1}')
#NAME=$(echo $USER | awk -F":" '{printf $2}')
if [[ $@ =~ (.*)":"(.*)":"(.*)":"(.*) ]]; then
	ID=${BASH_REMATCH[1]}
	NAME=${BASH_REMATCH[2]}
	SUR=${BASH_REMATCH[3]}
	USER=${BASH_REMATCH[4]}
	if [[ $(grep -c ^$ID: $USERLIST) == 0 ]]; then
		echo "$ID:$NAME:$SUR:$USER" >> $USERLIST
	fi
fi
echo "Hello $NAME"

