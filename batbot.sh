#!/bin/bash

# BaTbot current version
VERSION="1.4.3-ITA by eliafino"

# Inserire il token del BOT restituito da BotFather
TELEGRAMTOKEN="< token del BOT >";

# Inserire l'ID dell'utente per le notifiche di uso
PERSONALID="< ID utente personale >";

# creare il file allowed_users specificando gli ID degli utenti autorizzati all'invio dei comandi. Usare questo formato "@USERNAME1;@USERNAME2;@USERNAME3;"
ALLOWEDUSER="/etc/allowed_users";

# controllo nuovi messaggi ogni:
CHECKNEWMSG=1;

# Comandi
# rispettare questo formato: ["/miocomando"]='<system command>'
# per favore, ricordarsi di rimuovere gli esempi non necessari
# Per aggiungere questi comandi nei comandi personalizzati,
# usare la funzione /setcommands in BotFather

declare -A botcommands=(
	["/start"]='echo "Hi @FIRSTNAME, pleased to meet you :)"'
	["/myid"]='echo Your user id is: @USERID'
	["/myuser"]='echo Your username is: @USERNAME'
	["/ping ([a-zA-Z0-9]+)"]='echo Pong: @R1'
	["/uptime"]="uptime"
)

FIRSTTIME=0;
BOTPATH="/root";
echo -e "\nAvvio BaTbot v${VERSION}\n"
ABOUTME=`curl -s "https://api.telegram.org/bot${TELEGRAMTOKEN}/getMe"`
if [[ "$ABOUTME" =~ \"ok\"\:true\, ]]; then
	if [[ "$ABOUTME" =~ \"username\"\:\"([^\"]+)\" ]]; then
		echo -e "Nome BOT:\t ${BASH_REMATCH[1]}";
	fi

	if [[ "$ABOUTME" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
		echo -e "Nome Utente:\t ${BASH_REMATCH[1]}";
	fi

	if [[ "$ABOUTME" =~ \"id\"\:([0-9\-]+), ]]; then
		echo -e "Bot ID:\t\t ${BASH_REMATCH[1]}";
		BOTID=${BASH_REMATCH[1]};
	fi

else
	echo "Errore: forse token sbagliato... esco.";
	exit;
fi

if [ -e "${BOTPATH}/${BOTID}.lastmsg" ]; then
	FIRSTTIME=0;
else
	touch ${BOTPATH}/${BOTID}.lastmsg;
	FIRSTTIME=1;
fi

echo -e "\nBene... aspetto nuovi messaggi.\n"

while true; do
	MSGOUTPUT=$(curl -s "https://api.telegram.org/bot${TELEGRAMTOKEN}/getUpdates");
	MSGID=0;
	TEXT=0;
	FIRSTNAME="";
	LASTNAME="";
	echo -e "${MSGOUTPUT}" | while read -r line ; do
		if [[ "$line" =~ \"chat\"\:\{\"id\"\:([\-0-9]+)\, ]]; then
			CHATID=${BASH_REMATCH[1]};
		fi

		if [[ "$line" =~ \"message\_id\"\:([0-9]+)\, ]]; then
			MSGID=${BASH_REMATCH[1]};
		fi

		if [[ "$line" =~ \"text\"\:\"([^\"]+)\" ]]; then
			TEXT=${BASH_REMATCH[1]};
			LASTLINERCVD=${line};
		fi

		if [[ "$line" =~ \"username\"\:\"([^\"]+)\" ]]; then
			USERNAME=${BASH_REMATCH[1]};
		fi

		if [[ "$line" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
			FIRSTNAME=${BASH_REMATCH[1]};
		fi

		if [[ "$line" =~ \"last_name\"\:\"([^\"]+)\" ]]; then
			LASTNAME=${BASH_REMATCH[1]};
		fi

		if [[ "$line" =~ \"from\"\:\{\"id\"\:([0-9\-]+), ]]; then
			FROMID="${BASH_REMATCH[1]}";
		fi


		if [[ $MSGID -ne 0 && $CHATID -ne 0 ]]; then
			LASTMSGID=$(cat "${BOTID}.lastmsg");
			if [[ $MSGID -gt $LASTMSGID ]]; then
				if [[ $(echo ${botcommands[$TEXT]}) != "" ]]; then
					FIRSTNAMEUTF8=$(echo -e "$FIRSTNAME");
					echo "[chat ${CHATID}][da ${FROMID}] <${FIRSTNAMEUTF8} ${LASTNAME}> ${TEXT}";
					echo $MSGID > "${BOTID}.lastmsg";

					for s in "${!botcommands[@]}"; do
						if [[ "$TEXT" =~ ${s} ]]; then
							CMDORIG=${botcommands["$s"]};
							CMDORIG=${CMDORIG//@USERID/$FROMID};
							CMDORIG=${CMDORIG//@USERNAME/$USERNAME};
							CMDORIG=${CMDORIG//@FIRSTNAME/$FIRSTNAMEUTF8};
							CMDORIG=${CMDORIG//@LASTNAME/$LASTNAME};
							CMDORIG=${CMDORIG//@CHATID/$CHATID};
							CMDORIG=${CMDORIG//@MSGID/$MSGID};
							CMDORIG=${CMDORIG//@TEXT/$TEXT};
							CMDORIG=${CMDORIG//@FROMID/$FROMID};
							CMDORIG=${CMDORIG//@R1/${BASH_REMATCH[1]}};
							CMDORIG=${CMDORIG//@R2/${BASH_REMATCH[2]}};
							CMDORIG=${CMDORIG//@R3/${BASH_REMATCH[3]}};

							#controllo se l'utente è autorizzato
							UserAllowed=$(grep "@${FROMID};" $ALLOWEDUSER |wc -l)
						
							if [[ $UserAllowed -eq 1 ]]; then
								echo "Comando ${s} ricevuto, eseguo: ${CMDORIG}"
								CMDOUTPUT=`$CMDORIG`;
							else
								CMDOUTPUT="BOT Privato."
								echo "Utente non abilitato: Comando ${s} ricevuto da ${FIRSTNAMEUTF8}"
								curl -s -d "text=Utente non abilitato: Comando ${s} ricevuto da ${FIRSTNAMEUTF8}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null;
							fi

							if [ $FIRSTTIME -eq 1 ]; then
								echo "Messaggio vecchio, nessuna risposta all'utente.";
							elif [[ $UserAllowed -eq 1 ]]; then
								curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
								curl -s -d "text=Comando ${s} ricevuto da ${FIRSTNAMEUTF8}, eseguo: ${CMDORIG}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null;
							fi
						fi
					done
				else
					echo "Comando $TEXT non riconosciuto."
					echo $MSGID > "${BOTID}.lastmsg";
					curl -s -d "text=Comando $TEXT non riconosciuto.&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
					curl -s -d "text=Comando $TEXT non riconosciuto inviato da ${FIRSTNAMEUTF8}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null;

				fi
			fi
		fi
	done

	FIRSTTIME=0;

	read -t $CHECKNEWMSG answer;
	if [[ "$answer" =~ ^\.msg.([\-0-9]+).(.*) ]]; then
		CHATID=${BASH_REMATCH[1]};
		MSGSEND=${BASH_REMATCH[2]};
		curl -s -d "text=${MSGSEND}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null;
	elif [[ "$answer" =~ ^\.msg.([a-zA-Z]+).(.*) ]]; then
		CHATID=${BASH_REMATCH[1]};
		MSGSEND=${BASH_REMATCH[2]};
		curl -s -d "text=${MSGSEND}&chat_id=@${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null;
	fi


done

exit 0
