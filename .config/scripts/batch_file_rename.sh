#! /bin/sh
for f in *; do
  new=$(printf '%s' "$f" | sed -E '
    s/[[:space:]]+\[[^]]*\]//g;
    s/[[:space:]]+\././
  ')
  [[ "$f" == "$new" ]] && continue

  if [[ -e "$new" ]]; then
    echo "Skipping (collision): $f -> $new"
  else
    mv -- "$f" "$new"
  fi
done
