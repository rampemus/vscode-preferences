#!/usr/bin/env bash
# Builds the Finnish Vim spell file from hunspell-fi and installs it for nvim.
set -euo pipefail

URL="https://github.com/fginter/hunspell-fi/releases/download/0.2/fi-spell-0.2.xpi"
DEST="$HOME/.local/share/nvim/site/spell"
VIM_DEST="$HOME/.vim/spell"
WORKDIR="$(mktemp -d /tmp/fispell.XXXXXX)"
TOTAL_STEPS=6
STEP=0
# Share of the build bar spent reading fi_FI.dic; the rest is compressing and writing
READ_SHARE=90
START=$(date +%s)

cleanup() {
  [[ -n "${BUILD_PID:-}" ]] && kill "$BUILD_PID" 2>/dev/null || true
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

bar() { # bar <percent> <label>
  local pct=$1 width=30 filled
  filled=$((pct * width / 100))
  printf '\r\033[K[%s%s] %3d%% %s' \
    "$(printf '#%.0s' $(seq 1 "$filled") 2>/dev/null)" \
    "$(printf -- '-%.0s' $(seq 1 $((width - filled))) 2>/dev/null)" \
    "$pct" "$2"
}

step() {
  STEP=$((STEP + 1))
  bar $(((STEP - 1) * 100 / TOTAL_STEPS)) "$1"
  printf '\n'
  log "Step $STEP/$TOTAL_STEPS: $1"
}

command -v nvim >/dev/null || { echo "nvim not found" >&2; exit 1; }

cd "$WORKDIR"

step "Downloading dictionary"
curl -sfL -o fi.xpi "$URL"
log "Downloaded $(du -h fi.xpi | cut -f1)"

step "Extracting dictionary"
unzip -q fi.xpi
cd dictionaries/fi_FI
log "Extracted: $(ls | tr '\n' ' ')"

step "Building spell file with mkspell (slow, > 20 minutes)"
nvim --headless -u NONE -c 'mkspell! fi fi_FI' -c 'qa' >"$WORKDIR/mkspell.log" 2>&1 &
BUILD_PID=$!
BUILD_START=$(date +%s)
DIC_LINES=$(wc -l <fi_FI.dic)
while kill -0 "$BUILD_PID" 2>/dev/null; do
  elapsed=$(($(date +%s) - BUILD_START))
  # mkspell reports "line N, word M - <word>" while reading the .dic file
  recent=$(tail -c 4096 "$WORKDIR/mkspell.log" 2>/dev/null || true)
  line=$(grep -aoE 'line +[0-9]+' <<<"$recent" | tail -1 | grep -oE '[0-9]+' || true)
  phase=$(grep -aoE '(Compress|Writing|Done)[^:;]*' <<<"$recent" | tail -1 || true)
  if [[ -n "$phase" ]]; then
    pct=$((READ_SHARE + (100 - READ_SHARE) / 2))
    label="$phase"
  elif [[ -n "$line" ]]; then
    pct=$((line * READ_SHARE / DIC_LINES))
    label="reading line $line/$DIC_LINES"
  else
    pct=0
    label="reading affix file"
  fi
  ((pct > 99)) && pct=99
  bar "$pct" "$(printf 'mkspell %s, %02d:%02d' "$label" $((elapsed / 60)) $((elapsed % 60)))"
  sleep 1
done
printf '\n'
if ! wait "$BUILD_PID"; then
  BUILD_PID=""
  echo "mkspell failed:" >&2
  cat "$WORKDIR/mkspell.log" >&2
  exit 1
fi
BUILD_PID=""
[[ -f fi.utf-8.spl ]] || { echo "fi.utf-8.spl not produced" >&2; exit 1; }
log "Built fi.utf-8.spl ($(du -h fi.utf-8.spl | cut -f1))"

step "Creating $DEST and $VIM_DEST"
mkdir -p "$DEST" "$VIM_DEST"

step "Installing spell file for nvim and vim"
cp fi.utf-8.spl "$DEST/"
cp fi.utf-8.spl "$VIM_DEST/"

step "Cleaning up"
cd /
rm -rf "$WORKDIR"

bar 100 "Done in $(($(date +%s) - START))s"
printf '\n'
log "Installed $DEST/fi.utf-8.spl and $VIM_DEST/fi.utf-8.spl. Run :set spell in nvim or vim."
