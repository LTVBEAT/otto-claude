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
TAB=$(printf '\t')
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

# Barre rovesciate: si salvano così come sono, awk non le interpreta.
fb aggiungi tutti 'percorso C:\nuovo\tx' >/dev/null
grep -qxF -- '- percorso C:\nuovo\tx' "$percorso" || { echo "FAIL barre rovesciate: riga cambiata"; ERRORI=1; }

# Testo su più righe: diventa una riga sola, e si salva.
uscita=$(fb aggiungi tutti "$(printf 'riga uno\nriga due')"); c=$?
codice "più righe" $c 0
grep -qxF -- '- riga uno riga due' "$percorso" || { echo "FAIL più righe: non è una riga sola"; ERRORI=1; }

# Testo senza virgolette: tutte le parole, non solo la prima.
fb aggiungi tutti mai testo sopra >/dev/null
grep -qxF -- '- mai testo sopra' "$percorso" || { echo "FAIL senza virgolette: salvata solo una parola"; ERRORI=1; }

# Spazio in fondo al nome del cliente: sempre la stessa intestazione.
fb aggiungi "Learnn " "spazio in fondo" >/dev/null
[ "$(grep -c '^### ' "$percorso")" = 1 ] || { echo "FAIL spazio in fondo: due intestazioni"; ERRORI=1; }

# sezioni() <file>: le righe «sezione<TAB>voce» nell'ordine del file, per controllare dove sta ogni riga.
sezioni() { awk '/^## /{s=$0; c=""} /^### /{c=$0} /^- /{print s "\t" c "\t" $0}' "$1"; }

# File vuoto: le due sezioni tornano nell'ordine giusto, e il cliente non finisce sotto «tutti».
: > "$percorso"
fb aggiungi Learnn "b" >/dev/null; fb aggiungi tutti "a" >/dev/null
s=$(sezioni "$percorso")
contiene "file vuoto" "$s" "## Per tutti i clienti${TAB}${TAB}- a"
contiene "file vuoto" "$s" "## Per cliente${TAB}### Learnn${TAB}- b"
[ "$(grep -n '^## Per tutti i clienti' "$percorso" | cut -d: -f1)" -lt "$(grep -n '^## Per cliente' "$percorso" | cut -d: -f1)" ] \
  || { echo "FAIL file vuoto: sezioni in ordine sbagliato"; ERRORI=1; }

# Sezione «Per tutti» tolta a mano: torna prima di «Per cliente», e un cliente nuovo va sotto «Per cliente».
printf '# I tuoi feedback\n\n## Per cliente\n\n### Learnn\n- x\n' > "$percorso"
fb aggiungi tutti "a" >/dev/null; fb aggiungi Acme "c" >/dev/null
s=$(sezioni "$percorso")
contiene "sezione mancante" "$s" "## Per tutti i clienti${TAB}${TAB}- a"
contiene "sezione mancante" "$s" "## Per cliente${TAB}### Acme${TAB}- c"
contiene "sezione mancante" "$s" "## Per cliente${TAB}### Learnn${TAB}- x"

# Un cliente scritto sotto «Per tutti» da una versione vecchia del file torna sotto «Per cliente».
printf '## Per tutti i clienti\n- a\n### Learnn\n- b\n' > "$percorso"
fb aggiungi tutti "z" >/dev/null
contiene "cliente sotto tutti" "$(sezioni "$percorso")" "## Per cliente${TAB}### Learnn${TAB}- b"

# Se non si può scrivere: errore, uscita 1, niente «Salvato».
touch "$BASE/un-file"
uscita=$(env HOME="$BASE/casa" CLAUDE_PLUGIN_DATA="$BASE/un-file/dati" FEEDBACK_TEAM="$BASE/team.md" \
  bash "$QUI/feedback.sh" aggiungi tutti "non va" 2>&1); c=$?
codice "non scrivibile" $c 1
printf '%s' "$uscita" | grep -qF "Salvato" && { echo "FAIL non scrivibile: dice Salvato"; ERRORI=1; }

# Aggiornamento del plugin: la cartella del plugin si sostituisce, il feedback resta.
mkdir -p "$BASE/plugin-vecchio/scripts" "$BASE/plugin-nuovo/scripts"
cp "$QUI/feedback.sh" "$BASE/plugin-vecchio/scripts/"; cp "$QUI/feedback.sh" "$BASE/plugin-nuovo/scripts/"
env HOME="$BASE/casa2" CLAUDE_PLUGIN_DATA= bash "$BASE/plugin-vecchio/scripts/feedback.sh" aggiungi tutti "resta" >/dev/null
rm -rf "$BASE/plugin-vecchio"
contiene "dopo l'aggiornamento" "$(env HOME="$BASE/casa2" CLAUDE_PLUGIN_DATA= bash "$BASE/plugin-nuovo/scripts/feedback.sh" mostra)" "- resta"

# Uso sbagliato.
fb boh >/dev/null; codice "uso sbagliato" $? 2
fb aggiungi tutti >/dev/null; codice "aggiungi senza testo" $? 2

rm -rf "$BASE"
[ $ERRORI -eq 0 ] && echo "ok"
exit $ERRORI
