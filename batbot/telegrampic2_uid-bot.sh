#!/bin/bash
# Send Picture/Photo via telegram Messages to one or several USERID from Bot.
# Input file via first command line argument and comment via the following arguments 
# Originally Part of https://github.com/servidge/snowflakes 
# A picture paints a thousand words.

USERIDS=""
TELEGRAMTOKEN="<your telegram token>"
TIMEOUTUP="45"
URL="https://api.telegram.org/bot$TELEGRAMTOKEN"
URLPHOTO="$URL/sendPhoto"
EXECDAT="$(date "+%Y-%m-%d %H:%M")"
ERRORSUM="0"
ERRORCODE="0"
CAPMAXCHAR=200 # https://core.telegram.org/method/messages.sendMessage 4096 - somewhat

f_sendphoto () {
#function for reuse
for USERID in `echo $USERIDS`; do
        curl -s --max-time $TIMEOUTUP "$URLPHOTO" \
                -F "chat_id=$USERID" \
                -F "caption=${CAPTION}" \
                -F "photo="@$FILE"" > /dev/null
        ERRORCODE=$?
        ERRORSUM=$(($ERRORSUM+$ERRORCODE))
done
}

# set recipient
USERIDS="$1"
shift
FILE="$1"
# get photo
#raspistill -o $1 -w 1024 -h 768
curl -o $1 http://127.0.0.1/img/snapshot.cgi?size=4&quality=2 

if [ -f "$FILE" ] ; then
# "the first Parameter is a file so let's use this as text input."
        FILETYPE="$(file -b "$FILE")"
        if [[ $FILETYPE == "PNG image data"* ]] || [[ $FILETYPE == "JPEG image data"* ]] || [[ $FILETYPE == "GIF image data"* ]] || [[ $FILETYPE == "PC bitmap"* ]]; then
                shift
                CAPTION="$*"
                CAPTION="${CAPTION:0:$CAPMAXCHAR}"
                f_sendphoto
                exit $ERRORSUM
        else
        #the first Parameter is not a Photo.
                echo "no Photo"
                exit 253
        fi
else
        #the first Parameter is not a File.
        echo "First Parameter is not a File"
        exit 254
fi
