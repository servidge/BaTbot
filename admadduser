#!/bin/bash

ALLUSER=$HOME/.batbot/allowed_users
ALLSUPUSER=$HOME/.batbot/allowed_superusers

if [[ $(grep -x "$1" $ALLSUPUSER |wc -l) -eq 1 ]]; then
	if [[ $(grep -x "$2" $ALLUSER |wc -l) -eq 1 ]]; then
		echo "Utente $2 già presente"
	else
		echo $2 >> $ALLUSER
		echo "Aggiunto utente: $2"
	fi
else
	echo "Non sei abilitato ad aggiungere utenti"
fi
