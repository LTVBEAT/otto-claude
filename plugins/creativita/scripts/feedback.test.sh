#!/bin/bash
# Prova i feedback personali: bash plugins/creativita/scripts/feedback.test.sh
# HOME e cartella dati sono temporanee, e il feedback del team è un file finto: niente di vero viene toccato.
set -u
QUI=$(cd "$(dirname "$0")" && pwd)
BASE=$(mktemp -d)
ERRORI=0
DATI="$BASE/dati"
printf '# Feedback sulle creatività\n\n## Per tutti i clienti\n- riga del team\n' > "$BASE/team.md"

fb() { env HOME="$BASE/casa" CLAUDE_PLUGIN_DATA="$DATI" FEEDBACK_TEAM="$BASE/team.md" bash "$QUI/feedback.sh" "$@" 2>&1; }
contiene() { printf '%s' "$2" | grep -qF -- "$3" || { echo "FAIL $1: manca «$3»"; ERRORI=1; }; }
codice() { [ "$2" = "$3" ] || { echo "FAIL $1: codice $2, atteso $3"; ERRORI=1; }; }

# mostra senza file personale: c'è il team, e per la persona «Nessuno.».
uscita=$(fb mostra); c=$?
codice "mostra senza file personale" $c 0
contiene "mostra senza file personale" "$uscita" "- riga del team"
contiene "mostra senza file personale" "$(printf '%s' "$uscita" | sed -n '/^## I tuoi feedback/,$p')" "Nessuno."

# percorso: nella cartella dati, mai in quella del plugin, e il file nasce con le sezioni.
percorso=$(fb percorso); c=$?
codice "feedback percorso fuori dal plugin" $c 0
[ "$percorso" = "$DATI/feedback-personale.md" ] || { echo "FAIL feedback percorso fuori dal plugin: $percorso"; ERRORI=1; }
case "$percorso" in "$(dirname "$QUI")"*) echo "FAIL feedback percorso fuori dal plugin: è nel plugin"; ERRORI=1 ;; esac
[ -f "$percorso" ] || { echo "FAIL percorso: il file non c'è"; ERRORI=1; }

# Senza CLAUDE_PLUGIN_DATA: la stessa cartella dell'hook, sotto HOME.
p=$(env HOME="$BASE/casa" CLAUDE_PLUGIN_DATA= bash "$QUI/feedback.sh" percorso)
[ "$p" = "$BASE/casa/.claude/plugins/data/creativita-ltvbeat/feedback-personale.md" ] \
  || { echo "FAIL percorso senza CLAUDE_PLUGIN_DATA: $p"; ERRORI=1; }

# aggiungi tutti.
uscita=$(fb aggiungi tutti "mai testo sopra la foto (Sofia, 05/11)"); c=$?
codice "aggiungi tutti" $c 0
contiene "aggiungi tutti" "$uscita" "✅ Salvato: mai testo sopra la foto (Sofia, 05/11)"
contiene "aggiungi tutti" "$(sed -n '/^## Per tutti i clienti/,/^## Per cliente/p' "$percorso")" "- mai testo sopra la foto (Sofia, 05/11)"

# Stesso cliente due volte: una sola intestazione, due righe sotto, anche con le maiuscole diverse.
fb aggiungi Learnn "niente over 30" >/dev/null
fb aggiungi learnn "CTA sempre in basso" >/dev/null
[ "$(grep -c '^### ' "$percorso")" = 1 ] || { echo "FAIL stesso cliente: $(grep -c '^### ' "$percorso") intestazioni"; ERRORI=1; }
sotto=$(sed -n '/^### Learnn/,$p' "$percorso")
contiene "stesso cliente" "$sotto" "- niente over 30"
contiene "stesso cliente" "$sotto" "- CTA sempre in basso"

# Una riga per tutti dopo un cliente resta nella sua sezione, non in fondo al file.
fb aggiungi tutti "luce vera nelle scene" >/dev/null
contiene "tutti dopo un cliente" "$(sed -n '/^## Per tutti i clienti/,/^## Per cliente/p' "$percorso")" "- luce vera nelle scene"

# mostra: prima il team, poi la persona.
uscita=$(fb mostra)
team=$(printf '%s\n' "$uscita" | grep -n '^## Feedback del team' | cut -d: -f1)
miei=$(printf '%s\n' "$uscita" | grep -n '^## I tuoi feedback' | cut -d: -f1)
[ -n "$team" ] && [ -n "$miei" ] && [ "$team" -lt "$miei" ] || { echo "FAIL mostra: ordine delle sezioni"; ERRORI=1; }
contiene "mostra" "$uscita" "- mai testo sopra la foto (Sofia, 05/11)"
contiene "mostra" "$uscita" "- riga del team"

# Uso sbagliato.
fb boh >/dev/null; codice "uso sbagliato" $? 2
fb aggiungi tutti >/dev/null; codice "aggiungi senza testo" $? 2

rm -rf "$BASE"
[ $ERRORI -eq 0 ] && echo "ok"
exit $ERRORI
