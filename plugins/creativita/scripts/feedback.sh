#!/bin/bash
# I feedback sulle creatività. Lo lancia Claude, su istruzione della skill:
#   feedback.sh mostra                       prima il feedback del team (nel plugin), poi quelli della persona
#   feedback.sh percorso                     il file dei feedback della persona (lo crea se manca)
#   feedback.sh aggiungi <tutti|Cliente> <testo>   salva un feedback della persona, nella sua sezione
# Il file della persona sta nella cartella dati del plugin, che resta quando il plugin si aggiorna. Il feedback del
# team (feedback.md del plugin) lo cambia solo Max, a mano: questo script non ci scrive mai.
# Uscite: 0 ok, 2 uso sbagliato.
set -u

DATI=${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/creativita-ltvbeat}
PERSONALE="$DATI/feedback-personale.md"
TEAM=${FEEDBACK_TEAM:-$(dirname "$0")/../feedback.md}

uso() { sed -n '2,8p' "$0" | sed 's/^# *//' >&2; exit 2; }

crea() {
  [ -f "$PERSONALE" ] && return
  mkdir -p "$DATI"
  cat > "$PERSONALE" <<'EOF'
# I tuoi feedback sulle creatività

Le indicazioni che hai dato e che valgono sempre. Valgono solo per te: per tutto il team li sceglie Max.

## Per tutti i clienti

## Per cliente
EOF
}

case "${1:-}" in
  mostra)
    echo '## Feedback del team'
    echo
    if [ -f "$TEAM" ]; then cat "$TEAM"; else echo 'Nessuno.'; fi
    echo
    echo '## I tuoi feedback'
    echo
    if [ -f "$PERSONALE" ] && grep -q '^- ' "$PERSONALE"; then cat "$PERSONALE"; else echo 'Nessuno.'; fi
    ;;

  percorso)
    crea
    echo "$PERSONALE"
    ;;

  aggiungi)
    [ $# -ge 3 ] && [ -n "$2" ] && [ -n "$3" ] || uso
    dove=$2 testo=$3
    crea
    # Si legge tutto il file, si trova la fine della sezione giusta (prima della prossima intestazione, saltando le
    # righe vuote) e la riga nuova va lì. Un cliente nuovo va in fondo, sotto «## Per cliente».
    awk -v dove="$dove" -v riga="- $testo" '
      { r[NR] = $0 }
      END {
        cerca = (tolower(dove) == "tutti") ? "## Per tutti i clienti" : "### " dove
        inizio = 0
        for (i = 1; i <= NR; i++) if (tolower(r[i]) == tolower(cerca)) { inizio = i; break }
        if (inizio == 0) {
          for (i = 1; i <= NR; i++) print r[i]
          if (r[NR] != "") print ""
          print cerca; print riga
          exit
        }
        fine = NR
        for (i = inizio + 1; i <= NR; i++) if (r[i] ~ /^#/) { fine = i - 1; break }
        while (fine > inizio && r[fine] == "") fine--
        for (i = 1; i <= NR; i++) { print r[i]; if (i == fine) print riga }
      }' "$PERSONALE" > "$PERSONALE.tmp" && mv "$PERSONALE.tmp" "$PERSONALE"
    echo "✅ Salvato: $testo"
    ;;

  *) uso ;;
esac
