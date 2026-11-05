#!/bin/bash
# Prova i comandi della creazione creatività: bash plugins/creativita/hooks/comandi-creativita.test.sh
set -u
QUI=$(cd "$(dirname "$0")" && pwd)
BASE=$(mktemp -d)
DATI="$BASE/creativita-ltvbeat"
STATO="$DATI/modalita/s1"
OTTO="$BASE/otto-ltvbeat/modalita/s1"
ERRORI=0
manda() { printf '{"session_id":"s1","prompt":"%s"}' "$1" | CLAUDE_PLUGIN_DATA="$DATI" bash "$QUI/comandi-creativita.sh"; }
stato() { cat "$STATO" 2>/dev/null; }
atteso() { # $1 cosa si prova, $2 fase attesa ("" = spenta)
  [ "$(stato)" = "$2" ] || { echo "FAIL $1: atteso «$2», trovato «$(stato)»"; ERRORI=1; }
}
contiene() { # $1 cosa si prova, $2 uscita, $3 testo atteso
  printf '%s' "$2" | grep -qF -- "$3" || { echo "FAIL $1: manca «$3»"; ERRORI=1; }
}
json() { python3 -c 'import json,sys; json.load(sys.stdin)' 2>/dev/null || { echo "FAIL $1: uscita non è JSON valido"; ERRORI=1; }; }

uscita=$(manda "/creativita on")
atteso "/creativita on" "analisi"
contiene "/creativita on" "$uscita" "Creazione creatività attiva"
printf '%s' "$uscita" | json "/creativita on"

uscita=$(manda "riadattami questa statica per Learnn")
contiene "messaggio in creazione" "$uscita" "CREAZIONE CREATIVITÀ ATTIVA"
contiene "messaggio in creazione" "$uscita" "$STATO"
printf '%s' "$uscita" | grep -qi "otto" && { echo "FAIL messaggio in creazione: nomina Otto"; ERRORI=1; }
manda 'una frase con \"virgolette\"' | json "messaggio con virgolette"

uscita=$(manda "/creativita off")
atteso "/creativita off" ""
contiene "/creativita off" "$uscita" "Creazione creatività spenta"
[ -z "$(manda "ciao")" ] || { echo "FAIL: a creazione spenta un messaggio non deve avere contesto"; ERRORI=1; }

manda "/creativita:creativita on" >/dev/null
atteso "/creativita:creativita on" "analisi"
manda "/CREATIVITA OFF" >/dev/null
atteso "/CREATIVITA OFF" ""

contiene "/creativita help" "$(manda "/creativita help")" "/creativita on"
contiene "/creativita help" "$(manda "/creativita help")" "/creativita configura"

# Configurazione e account: Claude lancia lo script dei controlli del plugin, la creazione non si accende.
uscita=$(manda "/creativita configura")
contiene "/creativita configura" "$uscita" "$(cd "$QUI/.." && pwd)/scripts/controlla.sh' configura"
contiene "/creativita configura" "$uscita" "whoami"
printf '%s' "$uscita" | json "/creativita configura"
atteso "/creativita configura" ""
uscita=$(manda "/creativita account")
contiene "/creativita account" "$uscita" "scripts/controlla.sh' account"
contiene "/creativita account" "$uscita" "higgsfield auth logout"
contiene "/creativita account, password da Max" "$uscita" "chiedile a Max"
printf '%s' "$uscita" | json "/creativita account"
[ -z "$(manda "puoi fare /creativita on per me")" ] || { echo "FAIL: un comando dentro una frase non va eseguito"; ERRORI=1; }
atteso "comando dentro una frase" ""

# Una modalità alla volta con il plugin Otto: accendere la creazione spegne la modalità Otto...
mkdir -p "$(dirname "$OTTO")" && echo on > "$OTTO"
contiene "/creativita on con Otto acceso" "$(manda "/creativita on")" "modalità Otto è spenta"
[ -f "$OTTO" ] && { echo "FAIL /creativita on: la modalità Otto è ancora accesa"; ERRORI=1; }
# ...e se dopo si riaccende Otto, vince Otto: la creazione si spegne e non aggiunge contesto.
echo on > "$OTTO"
[ -z "$(manda "chiedi a Otto come va TKART")" ] || { echo "FAIL: con Otto riacceso la creazione aggiunge contesto"; ERRORI=1; }
atteso "Otto riacceso dopo la creazione" ""

rm -rf "$BASE"
[ $ERRORI -eq 0 ] && echo "ok"
exit $ERRORI
