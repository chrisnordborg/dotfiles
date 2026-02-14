#!/bin/bash

mainFolder="$HOME/OneDrive/Obsidian/Alpha"
newNoteFolder="$mainFolder/_NewNotes/"
terminal="kitty"
timestamp=$(date +%F_%T | tr ':' '-')

newnote() {
  name=$(fzf --print-query --prompt "New note name: " --phony --no-preview <<< "" | head -n1)
  [ -z "$name" ] && name="$timestamp"
  "$terminal" nvim "$newNoteFolder$name.md"
}

selected() {
  mapfile -t files < <(find "$mainFolder" -type f -name "*.md" | sort -r)

  # Add "New" as fake file to top, filtered by --phony
  selection=$(printf "New\n%s\n" "${files[@]}" | \
    fzf --prompt "Search notes: " \
        --preview 'head -n 20 {}' \
        --preview-window=down:wrap \
        --bind 'enter:accept' \
        --bind 'ctrl-n:execute-silent(echo new)' \
        --header 'Enter = open | Ctrl-N = create new' \
        --no-sort)

  case "$selection" in
    New|"new")
      newnote
      ;;
    *)
      [ -f "$selection" ] && "$terminal" nvim "$selection"
      ;;
  esac
}

selected
