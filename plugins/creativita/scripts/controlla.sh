#!/bin/bash
# Controlli sul computer per la creazione creatività. Lo lancia Claude, su istruzione dell'hook:
#   controlla.sh configura   una riga ✅/❌ per collegamento, con l'unica azione da fare se manca
#   controlla.sh account     con quale account e workspace Higgsfield si è collegati
# Le verifiche che passano dagli MCP (Figma, lettura della wiki) le fa Claude dopo, con gli strumenti: il terminale
# non vede i connettori della sessione (Max, 06/11: Figma «Needs authentication» da terminale, ma funzionante).
# Il token di Higgsfield non si chiede mai alla CLI: finirebbe a schermo.

ATTESA=${CONTROLLA_ATTESA:-10}
FIGMA_SH=${FIGMA_SH:-$(dirname "$0")/figma.sh}
# Un comando con un tempo massimo: macOS non ha timeout, perl sì. Il comando gira come figlio di perl, che
# allo scadere lo ferma ed esce con 124: così bash non stampa «Alarm clock».
entro() {
  perl -e '$t = shift; $p = fork; if (!$p) { exec @ARGV } $SIG{ALRM} = sub { kill 9, $p; exit 124 };
    alarm $t; waitpid($p, 0); exit($? >> 8)' "$ATTESA" "$@" 2>&1
}

riga_otto() {
  if grep -q '"otto@ltvbeat"' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null; then
    echo '✅ Wiki dei clienti: plugin Otto installato'
  else
    echo '❌ Wiki dei clienti: manca il plugin Otto, che la legge. Nel terminale: curl -fsSL https://raw.githubusercontent.com/LTVBEAT/otto-claude/main/installa.sh | bash (il token te lo dà Max)'
  fi
}

# Il token personale per l'API di Figma: non blocca niente, senza si legge Figma con l'MCP.
riga_token_figma() {
  local riga
  riga=$(entro bash "$FIGMA_SH" verifica)
  case "$riga" in
    ✅*) echo "$riga" ;;
    '') echo "❌ Token Figma: l'API di Figma non risponde. Senza token il giro funziona lo stesso, con più chiamate all'MCP di Figma." ;;
    *) echo "$riga Senza token il giro funziona lo stesso, con più chiamate all'MCP di Figma." ;;
  esac
}

righe_higgsfield() {
  if ! command -v higgsfield >/dev/null 2>&1; then
    echo '❌ Higgsfield: CLI non installata. Nel terminale: npm i -g @higgsfield/cli'
    return
  fi
  echo '✅ Higgsfield: CLI installata'
  if entro higgsfield workspace list >/dev/null; then
    # Va bene qualsiasi account Higgsfield (Max, 06/11): si mostra solo con quale si è entrati, senza consigliare di
    # cambiarlo. Le scene si pagano con i crediti di quell'account.
    local email
    email=$(entro higgsfield account status --json | jq -r '.email // empty' 2>/dev/null)
    if [ -n "$email" ]; then
      echo "✅ Higgsfield: login fatto con $email"
    else
      echo '✅ Higgsfield: login fatto, ma non riesco a leggere con quale account: controllalo con /creativita account'
    fi
  else
    echo '❌ Higgsfield: login non fatto. Nel terminale: higgsfield auth login (si apre il browser: va bene qualsiasi account Higgsfield; se non ne hai uno, chiedi a Max)'
  fi
}

case "${1:-configura}" in
  configura)
    riga_otto
    riga_token_figma
    righe_higgsfield
    ;;
  account)
    if ! command -v higgsfield >/dev/null 2>&1; then
      echo 'CLI di Higgsfield non installata. Nel terminale: npm i -g @higgsfield/cli'
    elif ! entro higgsfield workspace list >/dev/null; then
      echo 'Nessun account collegato. Nel terminale: higgsfield auth login (si apre il browser: va bene qualsiasi account Higgsfield; se non ne hai uno, chiedi a Max)'
    else
      entro higgsfield account status
      entro higgsfield workspace status
    fi
    ;;
esac
