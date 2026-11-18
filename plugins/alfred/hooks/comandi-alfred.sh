#!/bin/bash
# Comandi di Alfred: «/alfred help» spiega i comandi, «/alfred doctor» controlla che tutto sia a posto
# (qui i controlli sul computer, sul server lo strumento stato_alfred). Hook UserPromptSubmit. Nessuna
# modalità e nessuno stato: per qualunque altro messaggio esce in silenzio. Solo bash, sed e grep:
# jq sui Mac del team può non esserci.
#
# I comandi non si bloccano: passano a Claude con l'istruzione di rispondere con una riga fissa.

INGRESSO=$(cat)

COMANDO=$(printf '%s' "$INGRESSO" \
  | grep -oiE '"prompt"[[:space:]]*:[[:space:]]*"[[:space:]]*/alfred(:alfred)?[[:space:]]+(help|doctor)[[:space:]]*"' \
  | grep -oiE '(help|doctor)[[:space:]]*"$' | tr -d '" ' | tr 'A-Z' 'a-z')
[ -z "$COMANDO" ] && exit 0

RISPONDI='L'"'"'utente ha scritto un comando del plugin Alfred, già eseguito dal plugin. Non lanciare skill né subagent, non chiamare strumenti e non chiamare Alfred. Rispondi esattamente con il testo qui sotto, senza aggiungere niente prima o dopo:\n\n'

# L'oggetto «ltvbeat» di un file JSON, senza spazi: basta per cercarci dentro autoUpdate.
oggetto_ltvbeat() {
  local testo resto livello=1 i c fuori=""
  [ -f "$1" ] || return 1
  testo=$(tr -d ' \t\r\n' < "$1") || return 1
  resto=${testo#*\"ltvbeat\":\{}
  [ "$resto" = "$testo" ] && return 1
  for ((i = 0; i < ${#resto}; i++)); do
    c=${resto:i:1}
    case $c in
      '{') livello=$((livello + 1)) ;;
      '}') livello=$((livello - 1)); [ $livello -eq 0 ] && break ;;
    esac
    fuori+=$c
  done
  printf '%s' "$fuori"
}

controlli_locali() {
  local radice versione cc sistema config automatico server
  radice=$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)
  versione=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$radice/.claude-plugin/plugin.json" 2>/dev/null \
    | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  VERSIONE_PLUGIN=${versione:-sconosciuta}

  cc=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  if [ -z "$cc" ]; then
    RIGA_CC='⚠️ Claude Code: versione non letta (normale nell'"'"'app desktop, che ha la sua copia: si aggiorna dal menu Claude, Check for Updates)'
  elif [ "$(printf '%s\n%s\n' 2.1.147 "$cc" | sort -V | head -1)" = 2.1.147 ]; then
    RIGA_CC="✅ Claude Code $cc"
  else
    RIGA_CC="❌ Claude Code $cc: troppo vecchio. Nel terminale scrivi claude update; nell'app, menu Claude, Check for Updates"
  fi

  case "$(uname -s 2>/dev/null)" in
    Darwin) sistema=Mac ;;
    MINGW* | MSYS* | CYGWIN*) sistema='Windows (Git Bash)' ;;
    Linux) sistema=Linux ;;
    *) sistema="$(uname -s 2>/dev/null)" ;;
  esac
  RIGA_SISTEMA="✅ Sistema: $sistema"

  config=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
  automatico=no
  for file in "$config/plugins/known_marketplaces.json" "$config/settings.json"; do
    oggetto_ltvbeat "$file" | grep -q '"autoUpdate":true' && automatico=si
  done
  if [ "$automatico" = si ]; then
    RIGA_AUTO='✅ Aggiornamento automatico acceso'
  else
    RIGA_AUTO='❌ Aggiornamento automatico spento: in Claude Code scrivi /plugin, scheda Marketplaces, ltvbeat, Enable auto-update'
  fi

  server=$(curl -s -m 5 https://otto-hermes.ltvalue.it/alfred/salute 2>/dev/null)
  case "$server" in
    *'"ok"'*) RIGA_SERVER='✅ Server di Alfred raggiungibile da questo computer' ;;
    *) RIGA_SERVER='❌ Server di Alfred non raggiungibile da questo computer: controlla la connessione (o la VPN)' ;;
  esac
}

case "$COMANDO" in
  doctor)
    controlli_locali
    CONTESTO='L'"'"'utente ha scritto /alfred doctor, il controllo del plugin Alfred. Non lanciare skill né subagent e non chiamare chiedi_a_alfred.\n1. Chiama lo strumento stato_alfred con versione_plugin uguale a '"$VERSIONE_PLUGIN"'.\n2. Rispondi solo con questo elenco, nell'"'"'ordine, aggiungendo in fondo le righe di stato_alfred così come sono:\n\n**Alfred doctor**\n'"$RIGA_SISTEMA"'\n'"$RIGA_CC"'\n'"$RIGA_AUTO"'\n'"$RIGA_SERVER"'\n\n3. Se stato_alfred non è disponibile o risponde con un errore, al posto delle sue righe scrivi: ❌ Collegamento a Alfred non riuscito: di solito manca il token o non è valido. In Claude Code scrivi /plugin configure alfred@ltvbeat e incolla il token di Alfred che ti ha dato Max; se non ce l'"'"'hai, chiedilo a lui.\n4. Se c'"'"'è almeno una riga con ❌, chiudi con una riga: Per farti aiutare, manda questo elenco a Max.'
    ;;
  help)
    CONTESTO="${RISPONDI}"'**ALFRED**, l'"'"'agente debrief e task di LTV: debrief delle call, task ed esperimenti dei clienti su TaskFlow, attese del cliente, registro di cosa ha funzionato.\n\n**I comandi**\n- `/alfred help` questo aiuto\n- `/alfred doctor` controlla che tutto funzioni (versione, token, aggiornamenti, collegamento)\n\n**Senza comandi**\n- Scrivi a Claude «chiedi ad Alfred le task aperte di Scuter»: Claude gli passa la domanda.\n- «Ho finito la landing di Birthday»: Claude lo dice ad Alfred, che propone come aggiornare la task.\n\n**Da sapere**\n- Alfred scrive su TaskFlow solo dopo il tuo ok, e per ora solo se sei Max o Antonio.\n- Campagne, report e knowledge LTV restano a Otto.'
    ;;
esac
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$CONTESTO"
