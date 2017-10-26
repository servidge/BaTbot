#!/bin/bash

# BaTbot current version
VERSION="1.4.4 - by Servidge"

# default Bot token 
TELEGRAMTOKEN="<your telegram token>";

# The admin / owners user ID for notifications. 
PERSONALID="admin/owner ID"

# Bot Directory
BOTDIR="$( cd "$( dirname "$0" )" && pwd )"
BATBOTCFG=$BOTDIR/.batbot

# File allowed_users with specifd IDs of authorized users to send/request commands. One ID per line.
ALLOWEDUSER=$BATBOTCFG/allowed_users
# Switch to ignore allowed_users file.
PUBLICBOT=false

# how many seconds between check for new messages
CHECKNEWMSG=10
CHECKBRAKE=1
CHECKINTER=2
CHECKMIN=5
CHECKMAX=45

# Logfilefunction
LOGFILE=$BOTDIR/logtextfile.txt
#TIMESTAMP='date +%Y-%m-%dT%H:%M:%S'
f_logger () {
TIMESTAMP=`date +%Y-%m-%dT%H:%M:%S`
# Output to Console
echo "$TIMESTAMP $*"
# Output to File
echo "$TIMESTAMP $*" >> $LOGFILE
}

# Commands
# you have to use this exactly syntax: ["/mycommand"]='<system command>'
# please, don't forget to remove all example commands!
# To add these commands to custom commands,
# Use the function / setcommands in BotFather
declare -A botcommands=(
	["notextmessage"]="echo Message Type not supported, just text"
	["/start"]='exec ./userlist.sh @USERID:@FIRSTNAME:@LASTNAME'
	["/myid"]='echo Your user id is: @USERID'
	["/myuser"]='echo Your username is: @USERNAME'
	["/whoami"]="echo User id is: @USERID, Username is: @@USERNAME, Firstname: \"@FIRSTNAME\", Lastname: \"@LASTNAME\" "
	["/ping ([a-zA-Z0-9]+)"]='echo Pong: @R1'
	["/uptime"]="uptime"
	["/add ([0-9]+)"]='exec ./admadduser.sh @USERID @R1'
	["/del ([0-9]+)"]='exec ./admdeluser.sh @USERID @R1'
	["/listuser"]='exec ./admlistuser.sh @USERID'
	["/photo"]='exec ./telegrampic2_uid-bot.sh @USERID image.jpeg'
#	["/run (.*)"]="exec @R1"
)

FIRSTTIME=0

f_logger "Initializing BaTbot v${VERSION}"
ABOUTME=`curl -s "https://api.telegram.org/bot${TELEGRAMTOKEN}/getMe"`
if [[ "$ABOUTME" =~ \"ok\"\:true\, ]]; then
	if [[ "$ABOUTME" =~ \"username\"\:\"([^\"]+)\" ]]; then
		f_logger "Username BOT: ${BASH_REMATCH[1]}"
	fi

	if [[ "$ABOUTME" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
		f_logger "Firstname BOT: ${BASH_REMATCH[1]}"
	fi

	if [[ "$ABOUTME" =~ \"id\"\:([0-9\-]+), ]]; then
		f_logger "Bot ID: ${BASH_REMATCH[1]}"
		BOTID=${BASH_REMATCH[1]};
	fi

else
	f_logger "Error: maybe wrong token... exit.";
	exit;
fi

if [ -e "$BATBOTCFG/$BOTID.lastmsg" ]; then
	FIRSTTIME=0;
else
	touch $BATBOTCFG/$BOTID.lastmsg
	FIRSTTIME=1;
fi

if [ "$PUBLICBOT" = true ] ; then
	f_logger "+++" 
	f_logger "+++ Public Bot. Allowed Users are ignored. " 
	f_logger "+++ be careful." 
	f_logger "+++" 
fi

f_logger "Done. Waiting for new messages..."
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
			LASTNAME="UnconfigureD"
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
			# Check if the user is authorized
			UserAllowed=$(grep -c -x "${FROMID}" $ALLOWEDUSER)
			LASTMSGID=$(cat "${BATBOTCFG}/${BOTID}.lastmsg")
			FIRSTNAMEUTF8=$(echo -e "$FIRSTNAME")
			if [[ $MSGID -gt $LASTMSGID ]]; then
				if [ "$PUBLICBOT" = true ] ; then
					f_logger "Public Bot. Allowed Users are ignored. ${FROMID} was $UserAllowed" 
					UserAllowed="1"
					$BOTDIR/userlist.sh ${FROMID}:${FIRSTNAMEUTF8}:${LASTNAME}
				fi
				if grep -qe "$(echo $TEXT | awk '{print $1}')" <(echo "${!botcommands[@]}"); then
					f_logger "chat ${CHATID} from ${FROMID} ${USERNAME} - ${FIRSTNAMEUTF8} ${LASTNAME} -- ${TEXT}";
					echo $MSGID > "${BATBOTCFG}/${BOTID}.lastmsg"
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
								f_logger "Command ${s} received, running cmd: ${CMDORIG}"
								CMDOUTPUT=`$CMDORIG`
								f_logger "Output is ${CMDOUTPUT}"
								if [[ $FIRSTTIME -eq 1 || $DATEDIFF -gt $(($CHECKNEWMSG * 2 + 15 )) ]]; then
									f_logger "Old message, $DATEDIFF Sec, will not send any answer to user."
									curl -s -d "text=Old message, ${DATEDIFF} Sec&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
								else
									curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
									if [[ ${FROMID} != ${PERSONALID} ]]; then
										curl -s -d "text=${s} Received by ${FIRSTNAMEUTF8} ${LASTNAME} ${FROMID}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
									fi
								fi
							else
								if [[ ${s} == "/myid" ]]; then
									CMDOUTPUT=`$CMDORIG`
									f_logger "Output is ${CMDOUTPUT}"
									curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
								else
									CMDOUTPUT="Private Bot. You are not allowed! Your ID ${FROMID} is sent to the administrator to be enabled. maybe"
									f_logger "Unkonwn User: ${s} received from ${FIRSTNAMEUTF8} ${FROMID}"
									curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
									if [[ ${FROMID} != ${PERSONALID} ]]; then
										curl -s -d "text=User is not enabled: ${s} received from ${FIRSTNAMEUTF8} ${FROMID}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
									fi
									if [[ ${s} == "/start" ]]; then
										$BOTDIR/userlist.sh ${FROMID}:${FIRSTNAMEUTF8}:${LASTNAME}
									fi
								fi
							fi

						fi
					done
				else
					echo $MSGID > "${BATBOTCFG}/${BOTID}.lastmsg"
					if [[ $UserAllowed -eq 1 ]]; then
						f_logger "Command $TEXT not recognized."
						curl -s -d "text=Command $TEXT not recognized.&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
						if [[ ${FROMID} != ${PERSONALID} ]]; then
							curl -s -d "text=Not recognized Command $TEXT Received from ${FROMID} ${FIRSTNAMEUTF8} ${LASTNAME}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
						fi
					else
						CMDOUTPUT="You are not authorized to execute this command!"
						f_logger "Command unkonwn: ${s} received from ${FROMID} ${FIRSTNAMEUTF8}"
						curl -s -d "text=${CMDOUTPUT}&chat_id=${CHATID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
						if [[ ${FROMID} != ${PERSONALID} ]]; then
							curl -s -d "text=Command unkonwn: ${s} received from ${FROMID} ${FIRSTNAMEUTF8} ${LASTNAME}&chat_id=${PERSONALID}" "https://api.telegram.org/bot${TELEGRAMTOKEN}/sendMessage" > /dev/null
						fi
					fi
				fi
			fi
		fi
	done

	FIRSTTIME=0;

	NEWID=$(cat "${BATBOTCFG}/${BOTID}.lastmsg")
	if [[ "$NEWID" != $LASTID ]]; then
		CHECKNEWMSG=$CHECKMIN
	fi
	LASTID=$NEWID
	if [[ "$CHECKNEWMSG" -lt $CHECKMAX ]]; then
		if [[ "$CHECKBRAKE" -ge $CHECKINTER ]]; then
			CHECKNEWMSG=$((CHECKNEWMSG+1))
			CHECKBRAKE=1
		else
			CHECKBRAKE=$((CHECKBRAKE+1))
		fi
	fi

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
