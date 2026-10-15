#!/bin/bash
# Prova l'hook dei comandi di Mulan: bash plugins/mulan/hooks/comandi-mulan.test.sh
set -u
QUI=$(cd "$(dirname "$0")" && pwd)
ERRORI=0
prova() { # $1 prompt, $2 testo atteso nell'uscita ("" = uscita vuota)
  local uscita
  uscita=$(printf '{"session_id":"s1","prompt":"%s"}' "$1" | CLAUDE_PLUGIN_DATA="$(mktemp -d)" bash "$QUI/comandi-mulan.sh")
  if [ -z "$2" ]; then
    [ -z "$uscita" ] || { echo "FAIL «$1»: atteso niente, uscito: $uscita"; ERRORI=1; }
  else
    printf '%s' "$uscita" | grep -qF -- "$2" || { echo "FAIL «$1»: manca «$2»"; ERRORI=1; }
  fi
}
prova "/mulan doctor" "stato_mulan"
prova "/mulan:mulan doctor" "stato_mulan"
prova "/mulan help" "chiedi a Mulan"
prova "/mulan on" ""
prova "ciao" ""
prova "/otto doctor" ""
[ $ERRORI -eq 0 ] && echo "ok"
exit $ERRORI
