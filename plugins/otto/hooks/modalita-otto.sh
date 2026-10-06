#!/bin/bash
# Modalità Otto. Con «/otto on» ogni messaggio della sessione va a Otto e torna indietro tale e quale;
# con «/otto off» si torna a parlare con Claude. Hook UserPromptSubmit, una modalità per sessione.
# Solo bash, sed e grep: jq sui Mac del team può non esserci.

INGRESSO=$(cat)
SESSIONE=$(printf '%s' "$INGRESSO" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]*\)".*/\1/p' | head -1)
[ -z "$SESSIONE" ] && exit 0

CARTELLA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/otto-ltvbeat}/modalita"
mkdir -p "$CARTELLA" 2>/dev/null || exit 0
STATO="$CARTELLA/$SESSIONE"
find "$CARTELLA" -type f -mtime +7 -delete 2>/dev/null

COMANDO=$(printf '%s' "$INGRESSO" \
  | grep -oiE '"prompt"[[:space:]]*:[[:space:]]*"[[:space:]]*/otto[[:space:]]+(on|off)[[:space:]]*"' \
  | grep -oiE '(on|off)[[:space:]]*"$' | tr -d '" ' | tr 'A-Z' 'a-z')

# Il comando non arriva a Claude: lo blocchiamo qui e mostriamo solo l'esito.
if [ "$COMANDO" = "on" ]; then
  echo on > "$STATO"
  printf '%s\n' '{"decision":"block","reason":"Modalità Otto attiva: da ora parli con Otto, l'"'"'agente di LTV. Per tornare a Claude scrivi /otto off"}'
  exit 0
fi
if [ "$COMANDO" = "off" ]; then
  if [ -f "$STATO" ]; then echo spenta > "$STATO"; fi
  printf '%s\n' '{"decision":"block","reason":"Modalità Otto spenta: torni a parlare con Claude."}'
  exit 0
fi

[ -f "$STATO" ] || exit 0
case "$(cat "$STATO")" in
  on)
    CONTESTO='MODALITÀ OTTO ATTIVA: l'"'"'utente ha scritto /otto on e il messaggio qui sotto è per Otto, non per te.\n1. Passalo a chiedi_a_otto parola per parola, senza riformularlo, completarlo o aggiungere niente.\n2. La tua risposta è il testo di Otto tale e quale: niente introduzione, commento, riassunto o formattazione tua, prima o dopo.\n3. Se ricevi un numero di pratica (run_...), di'"'"' solo che Otto sta lavorando e recupera la risposta con risultato_otto come dice la skill otto; poi riportala tale e quale.\n4. Se Otto chiede un'"'"'autorizzazione, riporta la sua richiesta e lascia decidere all'"'"'utente: il suo sì o no va ad autorizza_otto, non a chiedi_a_otto.\n5. Se l'"'"'utente vuole dare un file a Otto, segui la procedura della skill otto (prepara_consegna).\n6. Se Otto non risponde o dà errore, riporta l'"'"'errore così com'"'"'è.\nPer tornare a te l'"'"'utente scrive /otto off.'
    ;;
  spenta)
    rm -f "$STATO"
    CONTESTO='La modalità Otto è stata spenta con /otto off: da questo messaggio rispondi di nuovo tu, normalmente. Le richieste per Otto passano a lui solo quando servono, come dice la skill otto.'
    ;;
  *) exit 0 ;;
esac
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}\n' "$CONTESTO"
