#!/bin/bash
# Controlli sul computer per la creazione creatività. Lo lancia Claude, su istruzione dell'hook:
#   controlla.sh configura   una riga ✅/❌ per collegamento, con l'unica azione da fare se manca
#   controlla.sh account     con quale account e workspace Higgsfield si è collegati
# Le verifiche che passano dagli MCP (login Figma, lettura della wiki) le fa Claude dopo, con gli strumenti.
# Il token di Higgsfield non si chiede mai alla CLI: finirebbe a schermo.

ATTESA=${CONTROLLA_ATTESA:-10}
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

riga_figma() {
  local elenco
  if command -v claude >/dev/null 2>&1; then
    elenco=$(entro claude mcp list | grep -i 'mcp.figma.com')
    case "$elenco" in
      *Connected*) echo '✅ Figma: collegato' ;;
      '') echo '❌ Figma: manca il plugin di Figma. Nel terminale: claude plugin install figma@claude-plugins-official, poi riapri Claude Code' ;;
      *) echo '❌ Figma: manca il login. In Claude Code scrivi /mcp, scegli figma e fai Authenticate con il tuo account Figma' ;;
    esac
  elif grep -qE 'figma@|mcp\.figma\.com' "$HOME/.claude/plugins/installed_plugins.json" "$HOME/.claude.json" 2>/dev/null; then
    echo '⚠️ Figma: installato, il login lo controlla Claude'
  else
    echo '❌ Figma: manca il plugin di Figma. In Claude Code scrivi /plugin, cerca figma nel catalogo ufficiale e installalo'
  fi
}

righe_higgsfield() {
  if ! command -v higgsfield >/dev/null 2>&1; then
    echo '❌ Higgsfield: CLI non installata. Nel terminale: npm i -g @higgsfield/cli'
    return
  fi
  echo '✅ Higgsfield: CLI installata'
  if entro higgsfield workspace list >/dev/null; then
    echo '✅ Higgsfield: login fatto'
  else
    echo '❌ Higgsfield: login non fatto. Nel terminale: higgsfield auth login (si apre il browser: entra con l'"'"'account dell'"'"'agenzia)'
  fi
}

case "${1:-configura}" in
  configura)
    riga_otto
    riga_figma
    righe_higgsfield
    ;;
  account)
    if ! command -v higgsfield >/dev/null 2>&1; then
      echo 'CLI di Higgsfield non installata. Nel terminale: npm i -g @higgsfield/cli'
    elif ! entro higgsfield workspace list >/dev/null; then
      echo 'Nessun account collegato. Nel terminale: higgsfield auth login'
    else
      entro higgsfield account status
      entro higgsfield workspace status
    fi
    ;;
esac
