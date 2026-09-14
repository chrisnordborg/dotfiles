#!/usr/bin/env bash

workspace="$1"

if [[ -z "$workspace" ]]; then
    echo '{"text":"?","class":"error"}'
    exit 1
fi

# Current workspace
active=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')

# Does this workspace currently contain any windows?
occupied=$(hyprctl clients -j 2>/dev/null |
    jq --arg ws "$workspace" '
        any(.[]; (.workspace.id | tostring) == $ws)
    ')

classes=""

if [[ "$active" == "$workspace" ]]; then
    classes+="active "
fi

if [[ "$occupied" == "true" ]]; then
    classes+="occupied"
else
    classes+="empty"
fi

printf '{"text":"%s","class":"%s","tooltip":"Workspace %s"}\n' \
    "$workspace" "$classes" "$workspace"
