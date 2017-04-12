#!/bin/bash

ALLUSER=$HOME/.batbot/allowed_users
ALLSUPUSER=$HOME/.batbot/allowed_superusers

if [[ $(grep -x "$1" $ALLSUPUSER |wc -l) -eq 1 ]]; then
	if [[ $(grep -x "$2" $ALLUSER |wc -l) -eq 1 ]]; then
		grep -vx "$2" $ALLUSER > $ALLUSER.temp && mv $ALLUSER.temp $ALLUSER
		echo "Rimosso utente: $2"
	else
		echo "Utente $2 non presente"
	fi
else
	echo " Non sei abilitato a rimuovere utenti"
fi
