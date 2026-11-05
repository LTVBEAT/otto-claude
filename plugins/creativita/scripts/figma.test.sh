#!/bin/bash
# Prova le letture di Figma via API: bash plugins/creativita/scripts/figma.test.sh
# curl e il Portachiavi sono finti, nel PATH: nessuna chiamata vera a Figma.
set -u
QUI=$(cd "$(dirname "$0")" && pwd)
BASE=$(mktemp -d)
ERRORI=0
mkdir -p "$BASE/bin" "$BASE/risposte"

cat > "$BASE/bin/security" <<'EOF'
#!/bin/bash
case "${FINTO_TOKEN:-ok}" in
  assente) echo 'security: SecKeychainSearchCopyNext: The specified item could not be found in the keychain.' >&2; exit 44 ;;
  spazi) printf '  tok-segreto-123  \n' ;;
  *) printf 'tok-segreto-123\n' ;;
esac
EOF

# Il curl finto registra argomenti e stdin, e risponde con i file di risposte/ scelti dall'indirizzo.
cat > "$BASE/bin/curl" <<'EOF'
#!/bin/bash
echo "$*" >> "$FINTO_BASE/argomenti"
uscita=/dev/null; intestazioni=/dev/null; indirizzo=''
while [ $# -gt 0 ]; do
  case "$1" in
    -K) [ "$2" = - ] && cat >> "$FINTO_BASE/stdin"; shift 2 ;;
    -D) intestazioni=$2; shift 2 ;;
    -o) uscita=$2; shift 2 ;;
    --data-binary) cp "${2#@}" "$FINTO_BASE/corpo"; shift 2 ;;
    -w|-X|-H) shift 2 ;;
    -*) shift ;;
    *) indirizzo=$1; shift ;;
  esac
done
case "$indirizzo" in
  https://cdn.finto/*) # un PNG vero di 1×1 pixel
    echo 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==' |
      base64 -D > "$uscita"; exit 0 ;;
esac
codice=200; attesa=''
case "${FINTO_FIGMA:-ok}" in
  403) codice=403 ;;
  429) [ -f "$FINTO_BASE/gia429" ] || { touch "$FINTO_BASE/gia429"; codice=429; attesa=1; } ;;
  429lungo) codice=429; attesa=120 ;;
esac
{ printf 'HTTP/2 %s\r\n' "$codice"; [ -n "$attesa" ] && printf 'retry-after: %s\r\n' "$attesa"; printf '\r\n'; } > "$intestazioni"
R="$FINTO_BASE/risposte"
if [ "$codice" != 200 ]; then
  echo '{"status":'"$codice"',"err":"finto"}' > "$uscita"
else
  case "$indirizzo" in
    */v1/me) cp "$R/me.json" "$uscita" ;;
    */v1/files/LRhz\?depth=*) cp "$R/file.json" "$uscita" ;;
    */v1/files/LRhz/nodes\?ids=53:671*) cp "$R/pagina.json" "$uscita" ;;
    */v1/files/LRhz/nodes\?ids=5:1*) cp "$R/asset.json" "$uscita" ;;
    */v1/files/LRhz\?ids=5:9) cp "$R/catena.json" "$uscita" ;;
    */v1/files/LRhz\?ids=5:99) cp "$R/catena-vuota.json" "$uscita" ;;
    */v1/files/LRhz/nodes\?ids=5:9) cp "$R/didascalia.json" "$uscita" ;;
    */v1/files/LRhz/nodes\?ids=5:99) cp "$R/didascalia-vuota.json" "$uscita" ;;
    */v1/files/LRhz/nodes\?ids=5:8,5:7,5:6) cp "$R/antenati.json" "$uscita" ;;
    */v1/files/LRhz/nodes\?ids=5:98) cp "$R/antenati-vuoti.json" "$uscita" ;;
    */v1/files/LRhz/images) cp "$R/riempimenti.json" "$uscita" ;;
    */v1/images/LRhz\?*)
      ids=$(printf '%s' "$indirizzo" | sed -E 's/.*ids=([^&]*).*/\1/')
      printf '%s' "$ids" | tr ',' '\n' | jq -R --arg nullo "${FINTO_NULLO:-}" -s \
        'split("\n") | map(select(. != "")) | {images: (map({key: ., value: (if . == $nullo then null else "https://cdn.finto/\(.)" end)}) | from_entries)}' > "$uscita" ;;
    *) codice=404; echo '{"status":404}' > "$uscita" ;;
  esac
fi
printf '%s' "$codice"
EOF
chmod +x "$BASE/bin/security" "$BASE/bin/curl"

echo '{"id":"u1","handle":"Massimo","email":"massimo@ltv.it"}' > "$BASE/risposte/me.json"
PAGINA='{"id":"53:671","name":"B10_ 3.11.2026","type":"CANVAS","children":[
  {"id":"53:700","name":"B10_ 3.11.2026 - C1 - 9:16","type":"FRAME","absoluteBoundingBox":{"x":4200,"y":0,"width":1080,"height":1920}},
  {"id":"53:701","name":"B10_ 3.11.2026 - C1 - 1:1","type":"FRAME","absoluteBoundingBox":{"x":5400,"y":0.4,"width":1080,"height":1080},
   "children":[{"id":"53:702","name":"Headline","type":"TEXT","absoluteBoundingBox":{"x":5465,"y":300,"width":900,"height":120}}]}]}'
echo "{\"document\":{\"id\":\"0:0\",\"type\":\"DOCUMENT\",\"children\":[$PAGINA]}}" > "$BASE/risposte/file.json"
echo "{\"nodes\":{\"53:671\":{\"document\":$PAGINA}}}" > "$BASE/risposte/pagina.json"
cat > "$BASE/risposte/asset.json" <<'EOF'
{"nodes":{"5:1":{"document":{"id":"5:1","name":"Asset · 03 Immagini","type":"FRAME","children":[
  {"id":"5:2","name":"Foto aula","type":"RECTANGLE","fills":[{"type":"IMAGE","imageRef":"aaa"}]},
  {"id":"5:3","name":"Didascalia","type":"TEXT","fills":[{"type":"SOLID"}]},
  {"id":"5:4","name":"Schermata app","type":"FRAME","fills":[],"children":[
    {"id":"5:5","name":"Schermo","type":"RECTANGLE","fills":[{"type":"IMAGE","imageRef":"bbb"}]}]}]}}}}
EOF
# Brand kit vero: il nome dell'asset è un testo nella didascalia, l'immagine sta nel riquadro accanto dello stesso
# «Figure». L'API, con ?ids=, dà solo la catena dal documento al nodo.
cat > "$BASE/risposte/catena.json" <<'EOF'
{"document":{"id":"0:0","type":"DOCUMENT","children":[{"id":"3:2","type":"CANVAS","name":"Brand kit","children":[
  {"id":"5:6","type":"FRAME","name":"Container","children":[{"id":"5:7","type":"FRAME","name":"Figure","children":[
    {"id":"5:8","type":"FRAME","name":"Figcaption","children":[{"id":"5:9","type":"TEXT","name":"foto-aula.png"}]}]}]}]}]}}
EOF
echo '{"nodes":{"5:9":{"document":{"id":"5:9","name":"foto-aula.png","type":"TEXT","fills":[{"type":"SOLID"}]}}}}' \
  > "$BASE/risposte/didascalia.json"
cat > "$BASE/risposte/antenati.json" <<'EOF'
{"nodes":{
 "5:8":{"document":{"id":"5:8","name":"Figcaption","type":"FRAME","children":[{"id":"5:9","name":"foto-aula.png","type":"TEXT"}]}},
 "5:7":{"document":{"id":"5:7","name":"Figure","type":"FRAME","children":[
   {"id":"5:10","name":"Image","type":"FRAME","fills":[{"type":"IMAGE","imageRef":"aaa"}]},
   {"id":"5:8","name":"Figcaption","type":"FRAME","children":[{"id":"5:9","name":"foto-aula.png","type":"TEXT"}]}]}},
 "5:6":{"document":{"id":"5:6","name":"Container","type":"FRAME","children":[
   {"id":"5:10","name":"Image","type":"FRAME","fills":[{"type":"IMAGE","imageRef":"aaa"}]},
   {"id":"5:11","name":"Image","type":"FRAME","fills":[{"type":"IMAGE","imageRef":"bbb"}]}]}}}}
EOF
cat > "$BASE/risposte/catena-vuota.json" <<'EOF'
{"document":{"id":"0:0","type":"DOCUMENT","children":[{"id":"3:2","type":"CANVAS","name":"Brand kit","children":[
  {"id":"5:98","type":"FRAME","name":"Note","children":[{"id":"5:99","type":"TEXT","name":"una nota"}]}]}]}}
EOF
echo '{"nodes":{"5:99":{"document":{"id":"5:99","name":"una nota","type":"TEXT"}}}}' > "$BASE/risposte/didascalia-vuota.json"
echo '{"nodes":{"5:98":{"document":{"id":"5:98","name":"Note","type":"FRAME","children":[{"id":"5:99","type":"TEXT"}]}}}}' \
  > "$BASE/risposte/antenati-vuoti.json"
echo '{"meta":{"images":{"aaa":"https://cdn.finto/aaa","bbb":"https://cdn.finto/bbb","ccc":"https://cdn.finto/ccc"}}}' \
  > "$BASE/risposte/riempimenti.json"
figma() { # variabili dei finti (NOME=valore), poi gli argomenti di figma.sh
  local vari=()
  while [ $# -gt 0 ] && [[ "$1" == *=* ]]; do vari+=("$1"); shift; done
  : > "$BASE/argomenti"; : > "$BASE/stdin"; rm -f "$BASE/gia429" "$BASE/corpo"
  env PATH="$BASE/bin:/usr/bin:/bin" FIGMA_CARTELLA="$BASE/img" FINTO_BASE="$BASE" ${vari[@]+"${vari[@]}"} \
    bash "$QUI/figma.sh" "$@" 2>&1
}
contiene() { printf '%s' "$2" | grep -qF -- "$3" || { echo "FAIL $1: manca «$3»"; ERRORI=1; }; }
manca() { printf '%s' "$2" | grep -qF -- "$3" && { echo "FAIL $1: non doveva esserci «$3»"; ERRORI=1; }; }
codice() { [ "$2" = "$3" ] || { echo "FAIL $1: codice $2, atteso $3"; ERRORI=1; }; }
TAB=$(printf '\t')

# verifica: con il token, senza, e con il token scaduto.
uscita=$(figma verifica); c=$?
contiene "verifica" "$uscita" "✅ Token Figma: Massimo (massimo@ltv.it)"; codice "verifica" $c 0
manca "verifica, token a schermo" "$uscita" "tok-segreto-123"
manca "token negli argomenti" "$(cat "$BASE/argomenti")" "tok-segreto-123"
contiene "token da stdin" "$(cat "$BASE/stdin")" 'header = "X-Figma-Token: tok-segreto-123"'
uscita=$(figma FINTO_TOKEN=assente verifica); c=$?
contiene "senza token" "$uscita" "❌ Token Figma: manca"; codice "senza token" $c 3
contiene "senza token" "$uscita" "security add-generic-password -U -s figma-token"
uscita=$(figma FINTO_FIGMA=403 verifica); c=$?
contiene "token scaduto" "$uscita" "scaduto o senza permessi"; codice "token scaduto" $c 3
manca "token scaduto, token a schermo" "$uscita" "tok-segreto-123"

# Token copiato con spazi e a capo: arriva pulito.
figma FINTO_TOKEN=spazi verifica >/dev/null
contiene "token con spazi" "$(cat "$BASE/stdin")" 'X-Figma-Token: tok-segreto-123"'

# struttura: una pagina, e il file intero.
uscita=$(figma struttura LRhz 53:671); c=$?
contiene "struttura pagina" "$uscita" "53:700${TAB}FRAME${TAB}B10_ 3.11.2026 - C1 - 9:16${TAB}4200${TAB}0${TAB}1080${TAB}1920${TAB}53:671"
contiene "struttura pagina" "$uscita" "53:671${TAB}CANVAS${TAB}B10_ 3.11.2026${TAB}${TAB}${TAB}${TAB}${TAB}-"
codice "struttura pagina" $c 0
contiene "struttura pagina, profondità" "$(cat "$BASE/argomenti")" "ids=53:671&depth=1"
uscita=$(figma struttura LRhz)
contiene "struttura file" "$uscita" "53:671${TAB}CANVAS${TAB}B10_ 3.11.2026${TAB}${TAB}${TAB}${TAB}${TAB}0:0"
contiene "struttura file" "$uscita" "53:701${TAB}FRAME"
contiene "struttura file, profondità" "$(cat "$BASE/argomenti")" "/v1/files/LRhz?depth=2"

# schermate: una sola chiamata per tutti i nodi, poi i download.
uscita=$(figma schermate LRhz 1:1 1:2 1:3); c=$?
codice "schermate" $c 0
[ "$(grep -c '/v1/images/' "$BASE/argomenti")" = 1 ] || { echo "FAIL schermate: più di una chiamata a /v1/images"; ERRORI=1; }
contiene "schermate" "$(cat "$BASE/argomenti")" "ids=1:1,1:2,1:3&format=png&scale=1"
for id in 1:1 1:2 1:3; do
  contiene "schermate" "$uscita" "$id${TAB}$BASE/img/LRhz/${id//:/-}.png"
  [ -s "$BASE/img/LRhz/${id//:/-}.png" ] || { echo "FAIL schermate: manca il file di $id"; ERRORI=1; }
done
uscita=$(figma FINTO_NULLO=1:3 schermate LRhz 1:1 1:3 --scala 2); c=$?
contiene "schermata nulla" "$uscita" "1:3${TAB}NON RENDERIZZATO"
contiene "schermata nulla" "$uscita" "1:1${TAB}"
codice "schermata nulla" $c 0
contiene "scala" "$(cat "$BASE/argomenti")" "scale=2"

# immagini: solo quelle sotto il nodo, con il formato vero.
uscita=$(figma immagini LRhz 5:1); c=$?
codice "immagini" $c 0
contiene "immagini" "$uscita" "5:2${TAB}Foto aula${TAB}$BASE/img/LRhz/5-2-immagine.png"
contiene "immagini" "$uscita" "5:5${TAB}Schermo${TAB}$BASE/img/LRhz/5-5-immagine.png"
manca "immagini" "$uscita" "ccc"
manca "immagini" "$uscita" "Didascalia"

# immagini sul nome di un asset: risale al riquadro più vicino che ha un'immagine, non al contenitore di tutte.
uscita=$(figma immagini LRhz 5:9); c=$?
codice "immagini dal nome" $c 0
contiene "immagini dal nome" "$uscita" "5:9 non ha immagini: uso il riquadro sopra, 5:7 (Figure)"
contiene "immagini dal nome" "$uscita" "5:10${TAB}Image${TAB}$BASE/img/LRhz/5-10-immagine.png"
manca "immagini dal nome, troppo in alto" "$uscita" "5:11"
contiene "immagini dal nome, una chiamata per gli antenati" "$(cat "$BASE/argomenti")" "nodes?ids=5:8,5:7,5:6"
uscita=$(figma immagini LRhz 5:99); c=$?
codice "immagini da nessuna parte" $c 0
contiene "immagini da nessuna parte" "$uscita" "Nessuna immagine sotto 5:99 né nei riquadri sopra"

# Limiti dell'API: un'attesa breve si fa, una lunga no.
uscita=$(figma FINTO_FIGMA=429 verifica); c=$?
codice "429 breve" $c 0
[ "$(grep -c '/v1/me' "$BASE/argomenti")" = 2 ] || { echo "FAIL 429 breve: non ha riprovato una volta"; ERRORI=1; }
inizio=$(date +%s); uscita=$(figma FINTO_FIGMA=429lungo verifica); c=$?; fine=$(date +%s)
codice "429 lungo" $c 4
[ $((fine - inizio)) -lt 5 ] || { echo "FAIL 429 lungo: ha aspettato"; ERRORI=1; }
[ "$(grep -c '/v1/me' "$BASE/argomenti")" = 1 ] || { echo "FAIL 429 lungo: ha riprovato"; ERRORI=1; }

# I commenti di Figma non si usano più: correzioni e feedback si danno in chat (Max, 05/11).
for comando in commenti rispondi reazione; do
  figma $comando LRhz 53:671 testo >/dev/null; codice "$comando non c'è più" $? 2
done

# Uso sbagliato.
figma boh >/dev/null; codice "uso sbagliato" $? 2
figma struttura >/dev/null; codice "struttura senza file" $? 2

rm -rf "$BASE"
[ $ERRORI -eq 0 ] && echo "ok"
exit $ERRORI
