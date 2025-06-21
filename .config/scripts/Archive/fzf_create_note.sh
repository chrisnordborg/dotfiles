#!/bin/bash

mainFolder="$HOME/OneDrive/Obsidian/Alpha"
newNoteFolder="$mainFolder/_NewNotes/"
terminal="kitty"
timestamp=$(date +%F_%T | tr ':' '-')

newnote() {
  name=$(fzf --print-query --prompt "New note: " --phony <<< "" | head -n1)
  [ -z "$name" ] && name="$timestamp"
  filepath="$newNoteFolder$name.md"
  "$terminal" nvim "$filepath" >/dev/null 2>&1
}

selected() {
  # Use ripgrep to search for .md files, showing content + relative path
  mapfile -t candidates < <(
    rg --no-heading --line-number --color=never "" "$mainFolder" --glob '*.md' -g '!.trash/**' 2>/dev/null |
    awk -F: '{print $1}' |
    sort -u
  )

  # If no notes found, just create a new one
  [ ${#candidates[@]} -eq 0 ] && { newnote; return; }

  # Call fzf with preview window to show first few lines of file
  selected_file=$(printf "%s\n" "${candidates[@]}" |
    fzf --prompt "Search notes: " \
        --preview "head -n 20 {}" \
        --preview-window=down:wrap \
        --bind "enter:accept" \
        --bind "ctrl-n:execute-silent(echo new)" \
        --header "Enter = open, Ctrl-N = new note" \
        --no-sort)

  # Handle selection
  if [ "$selected_file" = "new" ] || [ -z "$selected_file" ]; then
    newnote
  elif [ -f "$selected_file" ]; then
    "$terminal" nvim "$selected_file" >/dev/null 2>&1
  fi
}

selected
