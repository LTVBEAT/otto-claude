#!/bin/bash
# Installa Otto in Claude Code.
#   curl -fsSL https://raw.githubusercontent.com/LTVBEAT/otto-claude/main/installa.sh | bash
set -uo pipefail

INDIRIZZO="https://otto-hermes.ltvalue.it/mcp"
MINIMA="2.1.147"

echo ""
echo "  Otto per Claude Code"
echo "  --------------------"

if ! command -v claude >/dev/null 2>&1; then
  echo "  Non trovo Claude Code su questo Mac. Installalo da https://claude.com/code e rilancia."
  exit 1
fi
VERSIONE=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [ "$(printf '%s\n%s\n' "$MINIMA" "$VERSIONE" | sort -V | head -1)" != "$MINIMA" ]; then
  echo "  Claude Code $VERSIONE è troppo vecchio. Scrivi  claude update  e rilancia."
  exit 1
fi

echo "  1/3  Aggiungo il catalogo dei plugin LTV"
claude plugin marketplace add LTVBEAT/otto-claude >/dev/null 2>&1 \
  || claude plugin marketplace update ltvbeat >/dev/null 2>&1

echo "  2/3  Installo il plugin otto"
if ! claude plugin install otto@ltvbeat >/dev/null 2>&1; then
  claude plugin list 2>/dev/null | grep -q "otto@ltvbeat" \
    || { echo "  Installazione non riuscita. Avvisa Max."; exit 1; }
fi

echo "  3/3  Incolla il tuo token di Otto (te lo dà Max) e premi Invio."
echo "       Mentre incolli non vedi niente: è normale."
printf "       Token: "
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

printf '{"token":"%s"}' "$TOKEN" | claude plugin configure otto@ltvbeat --values-stdin >/dev/null 2>&1
ESITO=$?
unset TOKEN
if [ $ESITO -ne 0 ]; then
  echo "  Non sono riuscito a salvare il token. Avvisa Max."
  exit 1
fi

echo ""
if [ "$CODICE" = "000" ]; then
  echo "  Token salvato, ma adesso Otto non risponde (rete?). Riprova più tardi da Claude Code."
else
  echo "  Fatto! Il token è nel Portachiavi del Mac."
fi
echo ""
echo "  Chiudi e riapri Claude Code (terminale o app), poi scrivi:"
echo "     chiedi a Otto come vanno gli account di TKART questa settimana"
echo ""
