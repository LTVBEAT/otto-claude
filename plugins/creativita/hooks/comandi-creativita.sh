#!/bin/bash
# Creazione creatività. «/creativita on» accende la creazione per la sessione, «/creativita off» la spegne,
# «/creativita help» spiega i comandi. Accesa, a ogni messaggio Claude riceve le istruzioni del giro e il file
# in cui scrivere la fase, che la fascia mostra. Hook UserPromptSubmit, un file per sessione con la fase.
# Solo bash, sed e grep: jq sui Mac del team può non esserci.
#
# Una modalità alla volta con il plugin Otto: accendere la creazione spegne la modalità Otto, e se Otto si
# riaccende dopo, vince Otto e la creazione si spegne.
#
# I comandi non si bloccano: passano a Claude con l'istruzione di rispondere con una riga fissa.

INGRESSO=$(cat)
SESSIONE=$(printf '%s' "$INGRESSO" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]*\)".*/\1/p' | head -1)
[ -z "$SESSIONE" ] && exit 0

DATI="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/creativita-ltvbeat}"
CARTELLA="$DATI/modalita"
mkdir -p "$CARTELLA" 2>/dev/null || exit 0
STATO="$CARTELLA/$SESSIONE"
find "$CARTELLA" -type f -mtime +7 -delete 2>/dev/null
# La modalità Otto della stessa sessione, nella cartella dati del plugin Otto accanto a questa.
OTTO="$(dirname "$DATI")/otto-ltvbeat/modalita/$SESSIONE"

COMANDO=$(printf '%s' "$INGRESSO" \
  | grep -oiE '"prompt"[[:space:]]*:[[:space:]]*"[[:space:]]*/creativita(:creativita)?[[:space:]]+(on|off|help)[[:space:]]*"' \
  | grep -oiE '(on|off|help)[[:space:]]*"$' | tr -d '" ' | tr 'A-Z' 'a-z')

RISPONDI='L'"'"'utente ha scritto un comando del plugin creativita, già eseguito dal plugin. Non lanciare skill né subagent e non chiamare strumenti. Rispondi esattamente con il testo qui sotto, senza aggiungere niente prima o dopo:\n\n'

case "$COMANDO" in
  on)
    echo analisi > "$STATO"
    SPENTO=''
    if [ "$(cat "$OTTO" 2>/dev/null)" = on ]; then
      rm -f "$OTTO"
      SPENTO=' La modalità Otto è spenta.'
    fi
    CONTESTO="${RISPONDI}"'Creazione creatività attiva: passami una statica e dimmi per quale cliente riadattarla. Per uscire scrivi /creativita off.'"$SPENTO"
    ;;
  off)
    rm -f "$STATO"
    CONTESTO="${RISPONDI}"'Creazione creatività spenta: torni a parlare con Claude normalmente.'
    ;;
  help)
    CONTESTO="${RISPONDI}"'**Creazione creatività**: riadatti una statica per un cliente, nel suo brand, e la ritrovi su Figma a livelli.\n\n**I comandi**\n- `/creativita on` accendi la creazione: la fascia sopra il prompt mostra la fase del giro\n- `/creativita off` torni a parlare con Claude normalmente\n- `/creativita help` questo aiuto'
    ;;
  *)
    [ -f "$STATO" ] || exit 0
    # Otto acceso dopo la creazione: vince Otto.
    if [ "$(cat "$OTTO" 2>/dev/null)" = on ]; then
      rm -f "$STATO"
      exit 0
    fi
    # Il percorso va nel JSON: barre rovesciate e virgolette si escapano.
    FILE_FASE=$(printf '%s' "$STATO" | sed 's/\\/\\\\/g; s/"/\\"/g')
    CONTESTO='CREAZIONE CREATIVITÀ ATTIVA: l'"'"'utente lavora alle creatività dei clienti. Per riadattare una statica segui la skill creativita, se c'"'"'è.\nA ogni cambio di fase del giro (analisi, proposte, scena, figma) scrivi la fase nel file della sessione, così la fascia la mostra, con il comando Bash: printf '"'"'<fase>\\n'"'"' > '"'"''"$FILE_FASE"''"'"'\nPer uscire l'"'"'utente scrive /creativita off.'
    ;;
esac
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$CONTESTO"
