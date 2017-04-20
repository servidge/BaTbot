#!/bin/bash

# BaTbot current version
VERSION="1.4.3-1 - ITA by eliafino"

# Inserire il token del BOT restituito da BotFather
TELEGRAMTOKEN="< token del BOT >"

# Inserire l'ID dell'utente master per le notifiche di uso
PERSONALID=" ID utente master "

# Directory utente
BATBOTUSR=/root/.batbot

# creare il file allowed_users specificando gli ID degli utenti autorizzati all'invio dei comandi. Un ID per riga."
ALLOWEDUSER=$BATBOTUSR/allowed_users

# controllo nuovi messaggi ogni:
CHECKNEWMSG=1

# Comandi
# rispettare questo formato: ["/miocomando"]='<system command>'
# per favore, ricordarsi di rimuovere gli esempi non necessari
# Per aggiungere questi comandi nei comandi personalizzati,
# usare la funzione /setcommands in BotFather

declare -A botcommands=(
	["/start"]='exec userlist @USERID:@FIRSTNAME@LASTNAME'
	["/myid"]='echo Il tuo user ID Ã¨: @USERID'
	["/myuser"]='echo Il tuo nome utente Ã¨: @USERNAME'
	["/ping ([a-zA-Z0-9]+)"]='echo Pong: @R1'
	["/uptime"]="uptime"
	["/add ([0-9]+)"]='exec admadduser @USERID @R1'
	["/del ([0-9]+)"]='exec admdeluser @USERID @R1'
	["/lista"]='exec admlistuser @USERID'
#	["/run (.*)"]="exec @R1"
)

FIRSTTIME=0

echo -e "\nAvvio BaTbot v${VERSION}\n"
ABOUTME=`curl -s "https://api.telegram.org/bot${TELEGRAMTOKEN}/getMe"`
if [[ "$ABOUTME" =~ \"ok\"\:true\, ]]; then
	if [[ "$ABOUTME" =~ \"username\"\:\"([^\"]+)\" ]]; then
		echo -e "Nome BOT:\t ${BASH_REMATCH[1]}"
	fi

	if [[ "$ABOUTME" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
		echo -e "Nome Utente:\t ${BASH_REMATCH[1]}"
	fi

	if [[ "$ABOUTME" =~ \"id\"\:([0-9\-]+), ]]; then
		echo -e "Bot ID:\t\t ${BASH_REMATCH[1]}"
		BOTID=${BASH_REMATCH[1]};
	fi

else
	echo "Errore: forse token sbagliato... esco."
	exit;
fi

if [ -e "$BATBOTUSR/$BOTID.lastmsg" ]; then
	FIRSTTIME=0;
else
	touch $BATBOTUSR/$BOTID.lastmsg
	FIRSTTIME=1;
fi

echo -e "\nBene... aspetto nuovi messaggi.\n"

while true; do
	MSGOUTPUT=$(curl -s "https://api.telegram.org/bot${TELEGRAMTOKEN}/getUpdates")
	MSGID=0
	TEXT=0
	FIRSTNAME=""
	LASTNAME=""
	echo -e "${MSGOUTPUT}" | while read -r line ; do
		if [[ "$line" =~ \"chat\"\:\{\"id\"\:([\-0-9]+)\, ]]; then
			CHATID=${BASH_REMATCH[1]}
		fi

		if [[ "$line" =~ \"message\_id\"\:([0-9]+)\, ]]; then
			MSGID=${BASH_REMATCH[1]}
		fi

		if [[ "$line" != \"text\"\:\" ]]; then
			TEXT="notextmessage"
		fi

		if [[ "$line" =~ \"text\"\:\"([^\"]+)\" ]]; then
			TEXT=${BASH_REMATCH[1]}
			LASTLINERCVD=${line}
		fi

		if [[ "$line" =~ \"username\"\:\"([^\"]+)\" ]]; then
			USERNAME=${BASH_REMATCH[1]}
		fi

		if [[ "$line" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
			FIRSTNAME=${BASH_REMATCH[1]}
		fi

		if [[ "$line" != \"last_name\" ]]; then
			LASTNAME="UnconfigureD";
		fi

		if [[ "$line" =~ \"last_name\"\:\"([^\"]+)\" ]]; then
			LASTNAME=${BASH_REMATCH[1]}
		fi

		if [[ "$line" =~ \"from\"\:\{\"id\"\:([0-9\-]+), ]]; then
			FROMID="${BASH_REMATCH[1]}"
		fi

	 	if [[ "$line" =~ \"date\"\:([0-9]+)\, ]]; then
			DATE=${BASH_REMATCH[1]}
		fi

		if [[ $MSGID -ne 0 && $CHATID -ne 0 ]]; then
			#controllo se l'utente Ã¨ autorizzato
			UserAllowed=$(grep -x "${FROMID}" $ALLOWEDUSER |wc -l)
			LASTMSGID=$(cat "$BATBOTUSR/${BOTID}.lastmsg")
			FIRSTNAMEUTF8=$(echo -e "$FIRSTNAME")
			if [[ $MSGID -gt $LASTMSGID ]]; then
				if grep -qe "$(echo $TEXT | awk '{print $1}')" <(echo "${!botcommands[@]}"); then
					echo "[chat ${CHATID}][da ${FROMID}] <${FIRSTNAMEUTF8} ${LASTNAME}> ${TEXT}"
					echo $MSGID > "$BATBOTUSR/${BOTID}.lastmsg"
					for s in "${!botcommands[@]}"; do
						if [[ "$TEXT" =~ ${s} ]]; then
							DATENOW=$(date "+%s")
							DATEDIFF=$(( $DATENOW - $DATE ))
							CMDORIG=${botcommands["$s"]}
							CMDORIG=${CMDORIG//@USERID/$FROMID}
							CMDORIG=${CMDORIG//@USERNAME/$USERNAME}
							CMDORIG=${CMDORIG//@FIRSTNAME/$FIRSTNAMEUTF8}
							CMDORIG=${CMDORIG//@LASTNAME/$LASTNAME}
							CMDORIG=${CMDORIG//@CHATID/$CHATID}
							CMDORIG=${CMDORIG//@MSGID/$MSGID}
							CMDORIG=${CMDORIG//@TEXT/$TEXT}
							CMDORIG=${CMDORIG//@FROMID/$FROMID}
							CMDORIG=${CMDORIG//@R1/${BASH_REMATCH[1]}}
							CMDORIG=${CMDORIG//@R2/${BASH_REMATCH[2]}}
							CMDORIG=${CMDORIG//@R3/${BASH_REMATCH[3]}}

							if [[ $UserAllowed -eq 1 ]]; then
								echo "Comando ${s} ricevuto, eseguo: ${CMDORIG}"
								CMDOUTPUT=`$CMDORIG`
								if [[ $FIRSTTIME -eq 1 || $DATEDIFF -gt 20 ]]; then
									echo "Messaggio vecchio, nessuna risposta all'utente."
									curl -s -d "text=Messaggio vecchio&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
								else
									curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
									if [[ ${FROMID} != ${PERSONALID} ]]; then
										curl -s -d "text=${s} ricevuto da ${FIRSTNAMEUTF8} ${LASTNAME} ${FROMID}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
									fi
								fi
							else
								if [[ ${s} == "/ilmioid" ]]; then
									CMDOUTPUT=`$CMDORIG`
									curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
								else
									CMDOUTPUT="BOT Privato. Non sei autorizzato! Il tuo ID Ã¨: ${FROMID}, comunicalo all'amministratore per essere abilitato."
									echo "Utente non in lista: ${s} ricevuto da ${FIRSTNAMEUTF8} ${FROMID}"
									curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
									if [[ ${FROMID} != ${PERSONALID} ]]; then
										curl -s -d "text=Utente non abilitato: ${s} ricevuto da ${FIRSTNAMEUTF8} ${FROMID}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
									fi
									if [[ ${s} == "/start" ]]; then
										userlist ${FROMID}:${FIRSTNAMEUTF8}${LASTNAME}
									fi
								fi
							fi

						fi
					done
				else
					echo $MSGID > "$BATBOTUSR/${BOTID}.lastmsg"
					if [[ $UserAllowed -eq 1 ]]; then
						echo "Comando $TEXT non riconosciuto."
						curl -s -d "text=Comando $TEXT non riconosciuto.&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
						if [[ ${FROMID} != ${PERSONALID} ]]; then
							curl -s -d "text=$TEXT non riconosciuto ricevuto da ${FROMID} ${FIRSTNAMEUTF8} ${LASTNAME}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
						fi
					else
						CMDOUTPUT="Non sei autorizzato ad eseguire questo comando!"
						echo "Comando non abilitato: ${s} ricevuto da ${FROMID} ${FIRSTNAMEUTF8}"
						curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
						if [[ ${FROMID} != ${PERSONALID} ]]; then
							curl -s -d "text=Comando non abilitato: ${s} ricevuto da ${FROMID} ${FIRSTNAMEUTF8} ${LASTNAME}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
						fi
					fi
				fi
			fi
		fi
	done

	FIRSTTIME=0;

	read -t $CHECKNEWMSG answer
	if [[ "$answer" =~ ^\.msg.([\-0-9]+).(.*) ]]; then
		CHATID=${BASH_REMATCH[1]}
		MSGSEND=${BASH_REMATCH[2]}
		curl -s -d "text=${MSGSEND}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
	elif [[ "$answer" =~ ^\.msg.([a-zA-Z]+).(.*) ]]; then
		CHATID=${BASH_REMATCH[1]}
		MSGSEND=${BASH_REMATCH[2]}
		curl -s -d "text=${MSGSEND}&chat_id=@${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
	fi


done

exit 0