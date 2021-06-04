{%raw%}
#!/bin/bash

if [[ "${#@}" > 0 ]]; then
  while [ "$1" != "" ]; do
    case $1 in
      -n|--name)
        shift
        NAME="$1"
        ;;
      -m|--message)
        shift
        MSG="$1"
        ;;
      -h|--host)
        shift
        HOST="$1"
        ;;
      -w|--when)
        shift
        WHEN="$1"
        ;;
      -e|--encoded)
        shift
        encode="$1"
        ;;
    esac
    shift
  done
fi
{%endraw%}

SMTP_ADDR="{{ smtp_addr }}"
SENDER_EMAIL="{{ email_sender }}"
SENDER_PASS="{{ email_password }}"
MATTERMOST_TOKEN="{{ mattermost_token }}"
CHANNEL_ID="{{ mattermost_channel_id }}"
MATTERMOST_USER_ID="{{ mattermost_user_id }}"
FREE_ID="{{ free_id }}"
FREE_TOKEN="{{ free_token }}"


{%raw%}
# Emails
if [[ "$SENDER_PASS" != "" ]] && [[ "$SMTP_ADDR" != "" ]]; then
  f=$(mktemp /tmp/alert.XXXXXX)
  echo -e "$(cat header.txt)$HOST:$WHEN:$NAME\n\n$MSG" >> $f
  curl -s --ssl-reqd \
    --url "$SMTP_ADDR" \ 
    --user "$SENDER_EMAIL:$SENDER_PASS" \
    --mail-from "$SENDER_EMAIL"  \
    --mail-rcpt "$REC_EMAIL" \
    --upload-file "$f"
fi

# Mattermost
if [[ "$MATTERMOST_USER_ID" != "" ]] && [[ "$CHANNEL_ID" != "" ]] && [["$MATTERMOST_TOKEN" != "" ]] ; then
  curl -s 'https://yourlabs.chat/api/v4/posts' \
    --header "Authorization: Bearer $MATTERMOST_TOKEN"  \
    --data-raw '{"file_ids":[],
      "message":"'"$HOST $WHEN: $NAME\n$MSG"'",
      "user_id":"'"$MATTERMOST_USER_ID"'",
      "channel_id":"'"$CHANNEL_ID"'"}' > /dev/null
fi

# SMS (only work for FREE mobile)
# If don't work check if  mes-options ->  Notifications par SMS is activated
curl -s "https://smsapi.free-mobile.fr/sendmsg?user=$FREE_ID&pass=$FREE_TOKEN&msg=$encode"
{%endraw%}
