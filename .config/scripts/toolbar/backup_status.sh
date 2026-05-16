##!/bin/bash
jq -c . /tmp/backup-status.json 2>/dev/null \
  #|| echo '{"text":"󰆓 Idle","percentage":0,"class":"idle"}'

