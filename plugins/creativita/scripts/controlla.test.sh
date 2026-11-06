#!/bin/bash
# Prova i controlli della configurazione: bash plugins/creativita/scripts/controlla.test.sh
# Higgsfield e Claude Code sono finti, nel PATH; la casa è una cartella vuota.
set -u
QUI=$(cd "$(dirname "$0")" && pwd)
BASE=$(mktemp -d)
ERRORI=0

mkdir -p "$BASE/bin" "$BASE/casa/.claude/plugins"
cat > "$BASE/bin/higgsfield" <<'EOF'
#!/bin/bash
case "$FINTO_HF:$*" in
  nologin:workspace\ list*) echo 'Error: higgsfield: request failed (no response received)'; echo 'Hint: Run: hf auth login'; exit 2 ;;
  nologin:*) echo 'Hint: Run: hf auth login'; exit 2 ;;
  ok:workspace\ list*) echo 'LTV Beat  ws_123'; exit 0 ;;
  ok:account\ status\ --json*) echo '{"credits": 420, "email": "team@ltvalue.it", "subscription_plan_type": "pro"}'; exit 0 ;;
  ok:account\ status*) echo 'Email: team@ltvalue.it'; echo 'Credits: 420'; exit 0 ;;
  muto:workspace\ list*) echo 'LTV Beat  ws_123'; exit 0 ;;
  muto:*) exit 1 ;;
  ok:workspace\ status*) echo 'Workspace: LTV Beat (ws_123)'; exit 0 ;;
  lento:*) sleep 30 ;;
esac
EOF
cat > "$BASE/bin/claude" <<'EOF'
#!/bin/bash
case "$FINTO_FIGMA" in
  connesso) echo 'plugin:figma:figma: https://mcp.figma.com/mcp (HTTP) - ✔ Connected' ;;
  login) echo 'plugin:figma:figma: https://mcp.figma.com/mcp (HTTP) - ! Needs authentication' ;;
  assente) echo 'otto: https://otto-hermes.ltvalue.it/mcp (HTTP) - ✔ Connected' ;;
esac
EOF
cat > "$BASE/figma.sh" <<'EOF'
#!/bin/bash
case "${FINTO_TOKEN_FIGMA:-ok}" in
  ok) echo '✅ Token Figma: Massimo (massimo@ltv.it)' ;;
  assente) echo '❌ Token Figma: manca. Crealo su figma.com, poi: security add-generic-password -U -s figma-token -a "$USER" -w "$(pbpaste)"' >&2; exit 3 ;;
esac
EOF
chmod +x "$BASE/bin/higgsfield" "$BASE/bin/claude"

controlla() { # $1 = configura|account, poi variabili d'ambiente dei finti
  env PATH="$BASE/bin:/usr/bin:/bin" HOME="$BASE/casa" CONTROLLA_ATTESA=2 FIGMA_SH="$BASE/figma.sh" "${@:2}" \
    bash "$QUI/controlla.sh" "$1"
}
contiene() { printf '%s' "$2" | grep -qF -- "$3" || { echo "FAIL $1: manca «$3»"; ERRORI=1; }; }
manca() { printf '%s' "$2" | grep -qF -- "$3" && { echo "FAIL $1: non doveva esserci «$3»"; ERRORI=1; }; }

# Tutto a posto.
echo '{"plugins":{"otto@ltvbeat":[{}]}}' > "$BASE/casa/.claude/plugins/installed_plugins.json"
uscita=$(controlla configura FINTO_HF=ok FINTO_FIGMA=connesso)
contiene "tutto a posto" "$uscita" "✅ Wiki dei clienti: plugin Otto installato"
# Figma non lo giudica lo script: il terminale non vede i connettori della sessione (Max, 06/11). Lo fa Claude.
manca "Figma, non dallo script" "$uscita" "✅ Figma:"
contiene "tutto a posto" "$uscita" "✅ Higgsfield: CLI installata"
contiene "tutto a posto" "$uscita" "✅ Higgsfield: login fatto"
contiene "account Higgsfield" "$uscita" "con team@ltvalue.it"
manca "qualsiasi account va bene" "$uscita" "logout"
manca "qualsiasi account va bene" "$uscita" "agenzia"
contiene "tutto a posto" "$uscita" "✅ Token Figma: Massimo"
manca "tutto a posto" "$uscita" "❌"

# Token Figma assente: la riga dice come crearlo e che il giro va lo stesso; le altre restano ✅.
uscita=$(controlla configura FINTO_HF=ok FINTO_FIGMA=connesso FINTO_TOKEN_FIGMA=assente)
contiene "senza token Figma" "$uscita" "❌ Token Figma: manca"
contiene "senza token Figma" "$uscita" "security add-generic-password -U -s figma-token"
contiene "senza token Figma" "$uscita" "Senza token il giro funziona lo stesso"
contiene "senza token Figma" "$uscita" "✅ Higgsfield: login fatto"

# Otto assente.
echo '{"plugins":{}}' > "$BASE/casa/.claude/plugins/installed_plugins.json"
uscita=$(controlla configura FINTO_HF=ok FINTO_FIGMA=connesso)
contiene "senza Otto" "$uscita" "❌ Wiki dei clienti"
contiene "senza Otto" "$uscita" "LTVBEAT/otto-claude/main/installa.sh"
echo '{"plugins":{"otto@ltvbeat":[{}]}}' > "$BASE/casa/.claude/plugins/installed_plugins.json"

# Il terminale dice «Needs authentication» ma nella sessione Figma può funzionare: lo script non dice ❌.
manca "Figma, terminale senza login" "$(controlla configura FINTO_HF=ok FINTO_FIGMA=login)" "❌ Figma:"

# Higgsfield: CLI assente, login non fatto, CLI che non risponde.
rm "$BASE/bin/higgsfield.salvato" 2>/dev/null; mv "$BASE/bin/higgsfield" "$BASE/bin/higgsfield.salvato"
uscita=$(controlla configura FINTO_HF=ok FINTO_FIGMA=connesso)
contiene "senza CLI" "$uscita" "❌ Higgsfield: CLI non installata"
contiene "senza CLI" "$uscita" "npm i -g @higgsfield/cli"
mv "$BASE/bin/higgsfield.salvato" "$BASE/bin/higgsfield"
uscita=$(controlla configura FINTO_HF=nologin FINTO_FIGMA=connesso)
contiene "senza login" "$uscita" "❌ Higgsfield: login non fatto"
contiene "senza login" "$uscita" "higgsfield auth login"
contiene "senza login, qualsiasi account" "$uscita" "va bene qualsiasi account"
inizio=$(date +%s); uscita=$(controlla configura FINTO_HF=lento FINTO_FIGMA=connesso); fine=$(date +%s)
[ $((fine - inizio)) -lt 10 ] || { echo "FAIL CLI lenta: il controllo non si ferma da solo"; ERRORI=1; }
contiene "CLI lenta" "$uscita" "❌ Higgsfield: login non fatto"

# Login fatto ma account non leggibile: lo dice e rimanda a /creativita account.
contiene "account non letto" "$(controlla configura FINTO_HF=muto FINTO_FIGMA=connesso)" "/creativita account"

# Account: mostra email, crediti e workspace; senza login dice come entrare.
uscita=$(controlla account FINTO_HF=ok)
contiene "account" "$uscita" "team@ltvalue.it"
contiene "account" "$uscita" "Workspace: LTV Beat"
contiene "account senza login" "$(controlla account FINTO_HF=nologin)" "higgsfield auth login"
contiene "account senza login, qualsiasi account" "$(controlla account FINTO_HF=nologin)" "va bene qualsiasi account"

# Mai il token a schermo: lo script non chiama auth token.
grep -q "auth token" "$QUI/controlla.sh" && { echo "FAIL: lo script chiama auth token"; ERRORI=1; }

rm -rf "$BASE"
[ $ERRORI -eq 0 ] && echo "ok"
exit $ERRORI
