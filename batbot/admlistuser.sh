#!/bin/bash

ALLUSER=$HOME/.batbot/allowed_users
ALLSUPUSER=$HOME/.batbot/allowed_superusers
USERLIST=$HOME/.batbot/user_list

if [[ $(grep -x "$1" $ALLSUPUSER |wc -l) -eq 1 ]]; then
	for USER in $(cat $ALLUSER); do
		ID=$(grep $USER $USERLIST | awk -F":" '{printf $1}')
		NAME=$(grep $USER $USERLIST | awk -F":" '{printf $2}')
		echo "ID Telegram: $ID - Utente: $NAME"
	done
else
	echo "Non sei abilitato a visualizzare la lista utenti"
fi
