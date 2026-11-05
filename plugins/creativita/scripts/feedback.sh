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

TESTA='# I tuoi feedback sulle creatività

Le indicazioni che hai dato e che valgono sempre. Valgono solo per te: per tutto il team li sceglie Max.'

crea() {
  [ -f "$PERSONALE" ] && return
  mkdir -p "$DATI" 2>/dev/null && printf '%s\n\n## Per tutti i clienti\n\n## Per cliente\n' "$TESTA" > "$PERSONALE"
}

non_salvato() { echo "❌ Non salvato: non riesco a scrivere in $DATI" >&2; exit 1; }

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
    crea || non_salvato
    echo "$PERSONALE"
    ;;

  aggiungi)
    [ $# -ge 3 ] && [ -n "$2" ] || uso
    # Tutto quello che segue il cliente è il testo (anche senza virgolette), su una riga sola.
    dove=$(printf '%s' "$2" | sed 's/[[:space:]]*$//')
    testo=$(printf '%s' "${*:3}" | tr '\n\r\t' '   ' | sed 's/^ *//; s/ *$//')
    [ -n "$testo" ] || uso
    crea || non_salvato
    tmp=$(mktemp "$DATI/.feedback.XXXXXX" 2>/dev/null) || non_salvato
    # Il file si rifà intero, sempre nella stessa forma: la testa, «## Per tutti i clienti» con le sue righe,
    # «## Per cliente» con un «### Cliente» per cliente. Così una sezione tolta a mano torna, e un cliente non finisce
    # mai sotto «tutti». I valori passano dall'ambiente: awk non interpreta le barre rovesciate.
    if DOVE="$dove" RIGA="- $testo" TESTA="$TESTA" awk '
      function pulita(s) { sub(/[ \t]+$/, "", s); return s }
      BEGIN { stato = "testa"; nc = 0; nt = 0; ntesta = 0 }
      {
        l = pulita($0)
        if (l == "## Per tutti i clienti") { stato = "tutti"; next }
        if (l == "## Per cliente") { stato = "cliente"; cur = 0; next }
        if (l ~ /^### /) {
          nome = pulita(substr(l, 5)); k = tolower(nome)
          if (!(k in idx)) { idx[k] = ++nc; nomi[nc] = nome; n[nc] = 0 }
          cur = idx[k]; stato = "cliente"; next
        }
        if (stato == "testa") { testa[++ntesta] = $0; next }
        if (l == "") next
        if (stato == "tutti") tutti[++nt] = l
        else if (cur) voci[cur, ++n[cur]] = l
        else tutti[++nt] = l
      }
      END {
        riga = ENVIRON["RIGA"]; dove = ENVIRON["DOVE"]
        if (tolower(dove) == "tutti") tutti[++nt] = riga
        else {
          k = tolower(dove)
          if (!(k in idx)) { idx[k] = ++nc; nomi[nc] = dove; n[nc] = 0 }
          c = idx[k]; voci[c, ++n[c]] = riga
        }
        while (ntesta > 0 && testa[ntesta] ~ /^[ \t]*$/) ntesta--
        if (ntesta == 0) print ENVIRON["TESTA"]
        else for (i = 1; i <= ntesta; i++) print testa[i]
        print ""; print "## Per tutti i clienti"
        for (i = 1; i <= nt; i++) print tutti[i]
        print ""; print "## Per cliente"
        for (c = 1; c <= nc; c++) {
          print ""; print "### " nomi[c]
          for (i = 1; i <= n[c]; i++) print voci[c, i]
        }
      }' "$PERSONALE" > "$tmp" && mv "$tmp" "$PERSONALE"; then
      echo "✅ Salvato: $testo"
    else
      rm -f "$tmp"; non_salvato
    fi
    ;;

  *) uso ;;
esac
