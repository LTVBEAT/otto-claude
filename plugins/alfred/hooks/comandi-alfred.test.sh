#!/bin/bash
# Prova l'hook dei comandi di Alfred: bash plugins/alfred/hooks/comandi-alfred.test.sh
set -u
QUI=$(cd "$(dirname "$0")" && pwd)
ERRORI=0
prova() { # $1 prompt, $2 testo atteso nell'uscita ("" = uscita vuota)
  local uscita
  uscita=$(printf '{"session_id":"s1","prompt":"%s"}' "$1" | CLAUDE_PLUGIN_DATA="$(mktemp -d)" bash "$QUI/comandi-alfred.sh")
  if [ -z "$2" ]; then
    [ -z "$uscita" ] || { echo "FAIL «$1»: atteso niente, uscito: $uscita"; ERRORI=1; }
  else
    printf '%s' "$uscita" | grep -qF -- "$2" || { echo "FAIL «$1»: manca «$2»"; ERRORI=1; }
  fi
}
prova "/alfred doctor" "stato_alfred"
prova "/alfred:alfred doctor" "stato_alfred"
prova "/alfred help" "chiedi ad Alfred"
prova "/alfred help" "solo dopo il tuo ok"
printf '{"session_id":"s1","prompt":"/alfred help"}' | CLAUDE_PLUGIN_DATA="$(mktemp -d)" bash "$QUI/comandi-alfred.sh" \
  | grep -q "Chiara" && { echo "FAIL «/alfred help»: parla ancora di Chiara"; ERRORI=1; }
printf '{"session_id":"s1","prompt":"/alfred help"}' | CLAUDE_PLUGIN_DATA="$(mktemp -d)" bash "$QUI/comandi-alfred.sh" \
  | grep -qi "finestra" && { echo "FAIL «/alfred help»: parla ancora della finestra"; ERRORI=1; }
prova "/alfred on" ""
prova "ciao" ""
prova "/otto doctor" ""
prova "/mulan doctor" ""
prova "puoi fare /alfred doctor per me" ""
prova "/ALFRED DOCTOR" "stato_alfred"
for c in doctor help; do
  printf '{"session_id":"s1","prompt":"/alfred %s"}' "$c" | CLAUDE_PLUGIN_DATA="$(mktemp -d)" bash "$QUI/comandi-alfred.sh" \
    | python3 -c 'import json,sys; json.load(sys.stdin)' || { echo "FAIL: uscita di $c non è JSON valido"; ERRORI=1; }
done
[ $ERRORI -eq 0 ] && echo "ok"
exit $ERRORI
