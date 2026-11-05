#!/bin/bash
# Installa Otto (o Mulan, o la creazione creatività) in Claude Code.
#   curl -fsSL https://raw.githubusercontent.com/LTVBEAT/otto-claude/main/installa.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/LTVBEAT/otto-claude/main/installa.sh | bash -s mulan
#   curl -fsSL https://raw.githubusercontent.com/LTVBEAT/otto-claude/main/installa.sh | bash -s creativita
set -uo pipefail

PLUGIN="${1:-otto}"
case "$PLUGIN" in
  otto) NOME=Otto; INDIRIZZO=https://otto-hermes.ltvalue.it/mcp; PROVA="chiedi a Otto come vanno gli account di TKART questa settimana";;
  mulan) NOME=Mulan; INDIRIZZO=https://otto-hermes.ltvalue.it/mulan; PROVA="chiedi a Mulan le task aperte di Fibi";;
  # La creazione creatività non ha un server suo né un token: dopo l'installazione si collega con /creativita configura.
  creativita) NOME="Creazione creatività"; INDIRIZZO=""; PROVA="/creativita configura";;
  *) echo "Plugin sconosciuto: otto, mulan o creativita."; exit 1;;
esac
MINIMA="2.1.147"

echo ""
echo "  $NOME per Claude Code"
echo "  --------------------"

# Claude Code può esserci senza essere nel PATH: l'installer ufficiale lo mette in ~/.local/bin, e chi
# usa solo l'app desktop ne ha una copia in Application Support. Se non c'è da nessuna parte, lo installa.
if ! command -v claude >/dev/null 2>&1; then
  APP=$(ls -d "$HOME"/Library/Application\ Support/Claude/claude-code/*/*/claude.app/Contents/MacOS/claude 2>/dev/null | sort -V | tail -1)
  if [ -x "$HOME/.local/bin/claude" ]; then
    PATH="$HOME/.local/bin:$PATH"
  elif [ -n "$APP" ]; then
    PATH="$(dirname "$APP"):$PATH"
  else
    echo "  Claude Code non c'è su questo Mac: lo installo con l'installer di Anthropic (un minuto)."
    curl -fsSL https://claude.ai/install.sh </dev/null | bash >/dev/null 2>&1
    PATH="$HOME/.local/bin:$PATH"
    command -v claude >/dev/null 2>&1 \
      || { echo "  Non sono riuscito a installare Claude Code. Avvisa Max."; exit 1; }
  fi
fi

# Il catalogo si scarica con git, che su un Mac nuovo non funziona finché non ci sono gli Strumenti da
# riga di comando di Apple: senza, il catalogo non arriva e l'installazione si ferma al passo 2.
if ! git --version >/dev/null 2>&1; then
  xcode-select --install >/dev/null 2>&1
  echo "  Manca git, che serve a scaricare i plugin. Si è aperta una finestra di Apple: clicca"
  echo "  Installa, aspetta che finisca (qualche minuto) e poi rilancia questo stesso comando."
  exit 1
fi
VERSIONE=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [ "$(printf '%s\n%s\n' "$MINIMA" "$VERSIONE" | sort -V | head -1)" != "$MINIMA" ]; then
  echo "  Claude Code $VERSIONE è troppo vecchio. Scrivi  claude update  e rilancia."
  exit 1
fi

echo "  1/4  Aggiungo il catalogo dei plugin LTV"
# Se qualcosa va storto, l'errore vero si mostra: «Avvisa Max» da solo non dice cosa guardare.
mostra_errore() {
  echo "  $1 Manda a Max queste righe:"
  printf '%s\n' "$2" | grep -v '^[[:space:]]*$' | tail -4 | cut -c1-200 | sed 's/^/     /'
}
# Se c'era già, «add» fallisce e basta aggiornarlo; l'errore da mostrare resta quello di «add».
if ! ERRORE=$(claude plugin marketplace add LTVBEAT/otto-claude 2>&1); then
  claude plugin marketplace update ltvbeat >/dev/null 2>&1 \
    || { mostra_errore "Non riesco a scaricare il catalogo dei plugin." "$ERRORE"; exit 1; }
fi

echo "  2/4  Installo il plugin $PLUGIN"
if ! ERRORE=$(claude plugin install "$PLUGIN@ltvbeat" 2>&1); then
  claude plugin list 2>/dev/null | grep -q "$PLUGIN@ltvbeat" \
    || { mostra_errore "Installazione non riuscita." "$ERRORE"; exit 1; }
fi
# Se c'era già, lo porta all'ultima versione.
claude plugin update "$PLUGIN@ltvbeat" >/dev/null 2>&1

# Il catalogo LTV non è di Anthropic, quindi parte senza aggiornamenti automatici e la CLI non ha
# un'opzione per accenderli: si scrive autoUpdate sulla voce del catalogo nelle impostazioni.
# osascript c'è su ogni Mac; se il file non si legge, non lo tocca.
AUTOAGGIORNA='function run(argv) {
  var file = argv[0];
  var impostazioni = {};
  if ($.NSFileManager.defaultManager.fileExistsAtPath(file)) {
    var testo = $.NSString.stringWithContentsOfFileEncodingError(file, $.NSUTF8StringEncoding, null);
    if (testo.isNil()) throw new Error("non leggibile");
    impostazioni = JSON.parse(ObjC.unwrap(testo));
  }
  var cataloghi = impostazioni.extraKnownMarketplaces || {};
  var ltvbeat = cataloghi.ltvbeat || { source: { source: "github", repo: "LTVBEAT/otto-claude" } };
  ltvbeat.autoUpdate = true;
  cataloghi.ltvbeat = ltvbeat;
  impostazioni.extraKnownMarketplaces = cataloghi;
  var ok = $(JSON.stringify(impostazioni, null, 2) + "\n")
    .writeToFileAtomicallyEncodingError(file, true, $.NSUTF8StringEncoding, null);
  if (!ok) throw new Error("non scrivibile");
}'
echo "  3/4  Attivo gli aggiornamenti automatici di $NOME"
if ! osascript -l JavaScript -e "$AUTOAGGIORNA" "$HOME/.claude/settings.json" >/dev/null 2>&1; then
  echo "       Non ci sono riuscito. Fallo a mano in Claude Code: /plugin, scheda Marketplaces,"
  echo "       ltvbeat, Enable auto-update."
fi

if [ -z "$INDIRIZZO" ]; then
  echo ""
  echo "  Fatto! Chiudi e riapri Claude Code (terminale o app), poi scrivi:"
  echo "     $PROVA"
  echo "  e segui i passi: wiki dei clienti, Figma e Higgsfield."
  echo ""
  exit 0
fi

echo "  4/4  Incolla il tuo token di $NOME (te lo dà Max) e premi Invio."
echo "       Mentre incolli non vedi niente: è normale."
printf "       Token: "
TOKEN=""
read -rs TOKEN < /dev/tty
echo ""
if [ -z "$TOKEN" ]; then
  echo "  Nessun token inserito. Rilancia il comando quando ce l'hai."
  exit 1
fi

CODICE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 -X POST \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{}' "$INDIRIZZO")
if [ "$CODICE" = "401" ]; then
  unset TOKEN
  echo "  Il token non è valido: controlla di averlo copiato tutto, oppure chiedine uno nuovo a Max."
  exit 1
fi

printf '{"token":"%s"}' "$TOKEN" | claude plugin configure "$PLUGIN@ltvbeat" --values-stdin >/dev/null 2>&1
ESITO=$?
unset TOKEN
if [ $ESITO -ne 0 ]; then
  echo "  Non sono riuscito a salvare il token. Avvisa Max."
  exit 1
fi

echo ""
if [ "$CODICE" = "000" ]; then
  echo "  Token salvato, ma adesso $NOME non risponde (rete?). Riprova più tardi da Claude Code."
else
  echo "  Fatto! Il token è nel Portachiavi del Mac."
fi
echo ""
echo "  Chiudi e riapri Claude Code (terminale o app), poi scrivi:"
echo "     $PROVA"
echo ""
