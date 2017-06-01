# BaTbot v1.4.4 - Bash Telegram BOT

batbot.sh Telegram Bot written in Bash that can reply to user messages, execute commands, and others cool features. 

fork from v1.4.3-ITA by eliafino (source? theMiddleBlue/BaTbot) with the goal: 

~~some fixes, other directory structure and comments and announcements in english.~~ 

~~Does not work yet - work in progress 2017-04-12~~ works for me. done


## CHANGELOG

**v1.4.4 - by Servidge**
- other directory structure  
- comments and announcements translated back to english. 
- logfilefunction with timestamp instead of echo
- publicbot switch to ignore allowed_user
- grep count instead of wc
- reply message when other than text is received
- lastnamefix (set to UnconfigureD) when this field is unset not configured Telegram User. 

**v1.4.3-ITA by eliafino**
- cambiato variabile BOTPATH in NMSGPATH e messo impostabile il percorso di salvataggio. Tiene conto dei messaggi inviati per non processare quelli vecchi.
- aggiunto lista utenti accettati "allowed_user" by @do2sz
- aggiunta la notifica all'utente master dei comandi inviati al BOT
- aggiunta la notifica dell'invio di comandi non riconosciuti
- commenti e messaggi in italiano

**v1.4.3**
- fixed regex commands match

**v1.4.2**
- fixed text messages parser regex

**v1.4.1**
- fixed UTF-8 characters in username

## Index
- [Usage](#usage)
- [Simple Commands](#simple-commands)
- [Variables](#variables)
- [Commands with regex](#command-with-regex)
- [Send Message](#send-message)
- [TODO](#todo)

## Usage
./botbat

## Simple Commands
inside the script botbat you will find a list of example commands
that you can configure. For Example:
```
	["/hello"]="echo Hi"
```
this command trigger the /hello message from a user, 
execute the system command **echo Hi** and return the 
command output to the user via message.

Do you want to know your server uptime? no problem:
```
	["/uptime"]="/usr/bin/uptime" 
```

Free disk space via Telegram? let's do it:
```
	["/disks"]="/bin/df -h"
```

Execute external script:
```
	["/auth ([a-zA-Z0-9]+)"]="/usr/local/bin/auth.sh @R1"
```

**Don't try this at home**:
```
	["/exec (.*)"]="exec @R1"
```


## Variables
You can use variables! for example:
```
	["/hello"]="echo Hi @FIRSTNAME, pleased to meet you :)"
```

BaTbot show in console, and in real time, all received messages: 
```
+
Set Token to: ****
Check for new messages every: 1 seconds
+

Initializing BaTbot v1.4.3
Username:	wafblue_bot
First name:	wafblue
Bot ID:		****
Done. Waiting for new messages...

[chat **, from  **] <theMiddle - Andrea Menin> \/hello
Command /hello received, running cmd: echo Hi Andrea, pleased to meet you :)
```

### Varibales List
```
@USERID 	(int) ID of user who sent the triggered command
@USERNAME 	(string) Telegram Username of user
@FIRSTNAME	(string) The first name of user
@LASTNAME	(string) The last name of user
@CHATID 	(int) The chat ID where user sent a command
@MSGID 		(int) ID of message that triggered a command
@TEXT		(string) The full text of a received message
@FROMID		(int) ID of user that sent a message

Regex group extract
@R1 		Content of first group (.*)
@R2 		Content of second group (.*)
@R3 		Content of third group (.*)
```

### Command with regex
You can also configure a command with arguments, 
for example: "/ping 1234". All arguments can be 
regular expressions, For example:
```
	["/ping ([0-9]+)"]="echo Pong: @R1"

	["/blacklist ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)"]="/sbin/iptables -A INPUT -s @R1 -j DROP"

	["/whois ([a-zA-Z0-9\.\-]+)"]="/usr/bin/whois @R1"

	["/host ([a-zA-Z0-9\.\-]+)"]="/usr/bin/host @R1"
```

## Send message
When BaTbot is running, you can send message to chat id, by use the command **.msg** directly on console.
For example:
```
[chat 110440209, from  110440209] <theMiddle - Andrea Menin> hi bot :)
.msg 110440209 hey!!!
```

## TODO
- 2016-04-20 `[high  ]` ~~Fix text message parsing on API2.0~~ (thanks to **rauhmaru**)
- 2015-11-17 `[high  ]` Dynamic Regular Expression Group extraction
