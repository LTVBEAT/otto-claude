#!/bin/bash
# Modalità Otto. Con «/otto on» ogni messaggio della sessione va a Otto e torna indietro tale e quale;
# con «/otto off» si torna a parlare con Claude; «/otto help» spiega i comandi. Hook UserPromptSubmit,
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
  | grep -oiE '"prompt"[[:space:]]*:[[:space:]]*"[[:space:]]*/otto(:otto)?[[:space:]]+(on|off|help)[[:space:]]*"' \
  | grep -oiE '(on|off|help)[[:space:]]*"$' | tr -d '" ' | tr 'A-Z' 'a-z')

RISPONDI='L'"'"'utente ha scritto un comando del plugin Otto, già eseguito dal plugin. Non lanciare skill né subagent, non chiamare strumenti e non chiamare Otto. Rispondi esattamente con il testo qui sotto, senza aggiungere niente prima o dopo:\n\n'

case "$COMANDO" in
  on)
    echo on > "$STATO"
    CONTESTO="${RISPONDI}"'Modalità Otto attiva: da ora parli con Otto, l'"'"'agente di LTV. Per tornare a Claude scrivi /otto off. Tutti i comandi: /otto help'
    ;;
  off)
    rm -f "$STATO"
    CONTESTO="${RISPONDI}"'Modalità Otto spenta: torni a parlare con Claude.\n\n(Da qui in poi rispondi di nuovo tu, normalmente: le richieste per Otto passano a lui solo quando servono, come dice la skill otto. Questa riga tra parentesi non va scritta.)'
    ;;
  help)
    CONTESTO="${RISPONDI}"'**OTTO**, l'"'"'agente di LTV: vede gli account Meta e Google dei clienti, fa report e copy, conosce la knowledge.\n\n**I comandi**\n- `/otto on` da ora parli solo con Otto: scrivi e ti risponde lui, tale e quale\n- `/otto off` torni a parlare con Claude\n- `/otto help` questo aiuto\n\n**Senza comandi**\n- Scrivi a Claude «chiedi a Otto come va TKART questa settimana»: Claude gli passa la domanda.\n- Per dargli un file: «metti questo PDF nella knowledge di Qura».\n\n**Da sapere**\n- Prima di toccare un account (budget, pause) Otto chiede il permesso, e Claude lo chiede a te.\n- I report lunghi richiedono qualche minuto: Claude ti avvisa e recupera la risposta.\n- Otto ricorda la conversazione. Per ripartire da zero: «nuova conversazione con Otto».\n- Mai file con contatti, lead, ordini o pagamenti.'
    ;;
  *)
    [ -f "$STATO" ] && [ "$(cat "$STATO")" = on ] || exit 0
    CONTESTO='MODALITÀ OTTO ATTIVA: l'"'"'utente ha scritto /otto on e il messaggio qui sotto è per Otto, non per te.\n1. Passalo a chiedi_a_otto parola per parola, senza riformularlo, completarlo o aggiungere niente.\n2. La tua risposta è il testo di Otto tale e quale: niente introduzione, commento, riassunto o formattazione tua, prima o dopo.\n3. Se ricevi un numero di pratica (run_...), di'"'"' solo che Otto sta lavorando e recupera la risposta con risultato_otto come dice la skill otto; poi riportala tale e quale.\n4. Se Otto chiede un'"'"'autorizzazione, riporta la sua richiesta e lascia decidere all'"'"'utente: il suo sì o no va ad autorizza_otto, non a chiedi_a_otto.\n5. Se l'"'"'utente vuole dare un file a Otto, segui la procedura della skill otto (prepara_consegna).\n6. Se Otto non risponde o dà errore, riporta l'"'"'errore così com'"'"'è.\nPer tornare a te l'"'"'utente scrive /otto off.'
    ;;
esac
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$CONTESTO"
