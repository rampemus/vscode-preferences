#!/usr/bin/env bash
# Adds Finnish words missing from fi.utf-8.spl to the fi.utf-8.add word list.
# Candidates come from the given text files, or from a Finnish frequency list
# when no files are given. Voikko validates every candidate, so typos are skipped.
#
# Usage: ./nvimfispelladd.sh [file ...]
set -euo pipefail

FREQ_URL="https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/fi/fi_50k.txt"
DEST="$HOME/.config/nvim/spell"
VIM_DEST="$HOME/.vim/spell"
ADD="$DEST/fi.utf-8.add"
WORKDIR="$(mktemp -d /tmp/fispelladd.XXXXXX)"
trap 'rm -rf "$WORKDIR"' EXIT

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

command -v nvim >/dev/null || { echo "nvim not found" >&2; exit 1; }
if ! command -v voikkospell >/dev/null; then
  log "Installing libvoikko"
  brew install libvoikko
fi

if (($#)); then
  log "Extracting words from $# file(s)"
  # Letters, optionally joined by hyphens (e.g. "sähkö-auto")
  perl -CSD -ne 'print "$_\n" for /\p{L}+(?:-\p{L}+)*/g' "$@" >"$WORKDIR/words"
else
  log "Downloading frequency list"
  curl -sfL "$FREQ_URL" | cut -d' ' -f1 >"$WORKDIR/words"
fi
# Skip single letters; words in the add file are matched case-sensitively from
# their own form upwards, so keep the case they were written in
awk 'length($0) > 1' "$WORKDIR/words" | sort -u >"$WORKDIR/candidates"
log "Candidates: $(wc -l <"$WORKDIR/candidates" | tr -d ' ')"

log "Finding words fi.utf-8.spl rejects"
cat >"$WORKDIR/filter.lua" <<'EOF'
local out = io.open(vim.env.OUT, 'w')
for word in io.lines(vim.env.IN) do
  if #vim.spell.check(word) > 0 then
    out:write(word, '\n')
  end
end
out:close()
EOF
IN="$WORKDIR/candidates" OUT="$WORKDIR/rejected" \
  nvim --headless -u NONE -c 'set spell spelllang=fi' -c "luafile $WORKDIR/filter.lua" -c 'qa!'
log "Rejected by spell file: $(wc -l <"$WORKDIR/rejected" | tr -d ' ')"

log "Validating with Voikko"
# voikkospell prints "C: word" for correct and "W: word" for wrong words
voikkospell <"$WORKDIR/rejected" | sed -n 's/^C: //p' >"$WORKDIR/valid"
NEW=$(wc -l <"$WORKDIR/valid" | tr -d ' ')
log "Valid words to add: $NEW"
if ((NEW == 0)); then
  log "Nothing to add"
  exit 0
fi

mkdir -p "$DEST" "$VIM_DEST"
touch "$ADD"
sort -u "$ADD" "$WORKDIR/valid" -o "$ADD"
log "Compiling $ADD"
nvim --headless -u NONE -c "silent mkspell! $ADD" -c 'qa!'
cp "$ADD" "$ADD.spl" "$VIM_DEST/"

log "Added $NEW words. $ADD now has $(wc -l <"$ADD" | tr -d ' ') words."
log "Restart nvim or run :set spelllang=fi to reload."
