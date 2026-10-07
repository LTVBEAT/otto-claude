#!/bin/bash
# Modalità Otto. Con «/otto on» ogni messaggio della sessione va a Otto e torna indietro tale e quale;
# con «/otto off» si torna a parlare con Claude; «/otto help» spiega i comandi; «/otto doctor» controlla
# che tutto sia a posto (qui i controlli sul computer, sul server lo strumento stato_otto). Hook UserPromptSubmit,
# una modalità per sessione. Solo bash, sed e grep: jq sui Mac del team può non esserci.
#
# I comandi non si bloccano: l'app desktop mostra ogni blocco con un triangolo di pericolo. Passano a
# Claude con l'istruzione di rispondere con una riga fissa, che costa un turno breve.

INGRESSO=$(cat)
SESSIONE=$(printf '%s' "$INGRESSO" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]*\)".*/\1/p' | head -1)
[ -z "$SESSIONE" ] && exit 0

CARTELLA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/otto-ltvbeat}/modalita"
mkdir -p "$CARTELLA" 2>/dev/null || exit 0
STATO="$CARTELLA/$SESSIONE"
find "$CARTELLA" -type f -mtime +7 -delete 2>/dev/null

COMANDO=$(printf '%s' "$INGRESSO" \
  | grep -oiE '"prompt"[[:space:]]*:[[:space:]]*"[[:space:]]*/otto(:otto)?[[:space:]]+(on|off|help|doctor)[[:space:]]*"' \
  | grep -oiE '(on|off|help|doctor)[[:space:]]*"$' | tr -d '" ' | tr 'A-Z' 'a-z')

RISPONDI='L'"'"'utente ha scritto un comando del plugin Otto, già eseguito dal plugin. Non lanciare skill né subagent, non chiamare strumenti e non chiamare Otto. Rispondi esattamente con il testo qui sotto, senza aggiungere niente prima o dopo:\n\n'

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
  elif [ "$(printf '%s\n%s\n' 2.1.288 "$cc" | sort -V | head -1)" = 2.1.288 ]; then
    RIGA_CC="✅ Claude Code $cc"
  else
    RIGA_CC="❌ Claude Code $cc: troppo vecchio per la fascia di Otto. Nel terminale scrivi claude update; nell'app, menu Claude, Check for Updates"
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

  server=$(curl -s -m 5 https://otto-hermes.ltvalue.it/mcp/salute 2>/dev/null)
  case "$server" in
    *'"ok"'*) RIGA_SERVER='✅ Server di Otto raggiungibile da questo computer' ;;
    *) RIGA_SERVER='❌ Server di Otto non raggiungibile da questo computer: controlla la connessione (o la VPN)' ;;
  esac
}

case "$COMANDO" in
  on)
    echo on > "$STATO"
    CONTESTO="${RISPONDI}"'Modalità Otto attiva: da ora parli con Otto, l'"'"'agente di LTV. Per tornare a Claude scrivi /otto off. Tutti i comandi: /otto help'
    ;;
  off)
    rm -f "$STATO"
    CONTESTO="${RISPONDI}"'Modalità Otto spenta: torni a parlare con Claude.\n\n(Da qui in poi rispondi di nuovo tu, normalmente: le richieste per Otto passano a lui solo quando servono, come dice la skill otto. Questa riga tra parentesi non va scritta.)'
    ;;
  doctor)
    controlli_locali
    CONTESTO='L'"'"'utente ha scritto /otto doctor, il controllo del plugin Otto. Non lanciare skill né subagent e non chiamare chiedi_a_otto.\n1. Chiama lo strumento stato_otto con versione_plugin uguale a '"$VERSIONE_PLUGIN"'.\n2. Rispondi solo con questo elenco, nell'"'"'ordine, aggiungendo in fondo le righe di stato_otto così come sono:\n\n**Otto doctor**\n'"$RIGA_SISTEMA"'\n'"$RIGA_CC"'\n'"$RIGA_AUTO"'\n'"$RIGA_SERVER"'\n\n3. Se stato_otto non è disponibile o risponde con un errore, al posto delle sue righe scrivi: ❌ Collegamento a Otto non riuscito: di solito manca il token o non è valido. In Claude Code scrivi /plugin configure otto@ltvbeat e incolla il token che ti ha dato Max; se non ce l'"'"'hai, chiedilo a lui.\n4. Se c'"'"'è almeno una riga con ❌, chiudi con una riga: Per farti aiutare, manda questo elenco a Max.'
    ;;
  help)
    CONTESTO="${RISPONDI}"'**OTTO**, l'"'"'agente di LTV: vede gli account Meta e Google dei clienti, fa report e copy, conosce la knowledge.\n\n**I comandi**\n- `/otto on` da ora parli solo con Otto: scrivi e ti risponde lui, tale e quale\n- `/otto off` torni a parlare con Claude\n- `/otto help` questo aiuto\n- `/otto doctor` controlla che tutto funzioni (versione, token, aggiornamenti, collegamento)\n\n**Senza comandi**\n- Scrivi a Claude «chiedi a Otto come va TKART questa settimana»: Claude gli passa la domanda.\n- Per dargli un file: «metti questo PDF nella knowledge di Qura».\n\n**Da sapere**\n- Prima di toccare un account (budget, pause) Otto chiede il permesso, e Claude lo chiede a te.\n- I report lunghi richiedono qualche minuto: Claude ti avvisa e recupera la risposta.\n- Otto ricorda la conversazione. Per ripartire da zero: «nuova conversazione con Otto».\n- Mai file con contatti, lead, ordini o pagamenti.'
    ;;
  *)
    [ -f "$STATO" ] && [ "$(cat "$STATO")" = on ] || exit 0
    CONTESTO='MODALITÀ OTTO ATTIVA: l'"'"'utente ha scritto /otto on e il messaggio qui sotto è per Otto, non per te.\n1. Passalo a chiedi_a_otto parola per parola, senza riformularlo, completarlo o aggiungere niente.\n2. La tua risposta è il testo di Otto tale e quale: niente introduzione, commento, riassunto o formattazione tua, prima o dopo.\n3. Se ricevi un numero di pratica (run_...), di'"'"' solo che Otto sta lavorando e recupera la risposta con risultato_otto come dice la skill otto; poi riportala tale e quale.\n4. Se Otto chiede un'"'"'autorizzazione, riporta la sua richiesta e lascia decidere all'"'"'utente: il suo sì o no va ad autorizza_otto, non a chiedi_a_otto.\n5. Se l'"'"'utente vuole dare un file a Otto, segui la procedura della skill otto (prepara_consegna).\n6. Se Otto non risponde o dà errore, riporta l'"'"'errore così com'"'"'è.\nPer tornare a te l'"'"'utente scrive /otto off.'
    ;;
esac
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$CONTESTO"
