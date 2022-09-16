#!/bin/bash
# A script to send a meme to gamez Discord channel.  Intended to be triggered by cron.

post_meme () {
  curl -s -H 'Content-Type: application/json' --data "{\"content\" : \"$MEME \"}" "$WEBHOOK" > /dev/null
}

PRELUDE="but first, a joke... \n"
JOKE=$(curl -s https://meme-api.herokuapp.com/gimme | jq -r '.url')

post_meme
