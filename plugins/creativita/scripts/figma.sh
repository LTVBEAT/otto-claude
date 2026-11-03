#!/bin/bash
# Letture di Figma via API REST per la creazione creatività. Lo lancia Claude, su istruzione della skill:
#   figma.sh verifica                                 il token c'è e funziona, con quale account
#   figma.sh struttura <file> [nodo] [profondità]     una riga per nodo: id tipo nome x y larghezza altezza genitore
#   figma.sh schermate <file> <nodo>... [--scala N]   PNG di più nodi con una sola chiamata: id percorso
#   figma.sh immagini <file> <nodo>                   le immagini originali sotto un nodo: id nome percorso
# L'API non ha il tetto giornaliero dell'MCP. Le scritture (frame, testi, scene) restano all'MCP di Figma.
# Uscite: 0 ok, 1 errore, 2 uso sbagliato, 3 token mancante o non valido, 4 limite dell'API: con 3 e 4 si usa l'MCP.
# Il token sta nel Portachiavi (voce figma-token) e non si stampa mai: arriva a curl da stdin, non dagli argomenti.
set -u

API=https://api.figma.com
CARTELLA=${FIGMA_CARTELLA:-${TMPDIR:-/tmp}/creativita-figma}
ATTESA_MASSIMA=60
ISTRUZIONI='Crealo su figma.com (Impostazioni, Sicurezza, Personal access tokens: 90 giorni; File content Read, Comments Read and write, Current user Read), copialo e poi nel terminale: security add-generic-password -U -s figma-token -a "$USER" -w "$(pbpaste)"'

uso() { sed -n '2,6p' "$0" | sed 's/^# *//' >&2; exit 2; }

# chiama <metodo> <percorso> [file con il corpo JSON]: il corpo della risposta su stdout.
# Va usata come x=$(chiama ...) || exit $?: gli exit qui dentro escono solo dalla sottoshell.
chiama() {
  local metodo=$1 percorso=$2 corpo=${3:-} token tmp codice attesa tentativo opzioni
  token=$(security find-generic-password -s figma-token -w 2>/dev/null | tr -d '[:space:]')
  [ -n "$token" ] || { echo "❌ Token Figma: manca. $ISTRUZIONI" >&2; exit 3; }
  tmp=$(mktemp -d)
  opzioni=()
  [ "$metodo" = GET ] || opzioni+=(-X "$metodo")
  [ -n "$corpo" ] && opzioni+=(-H 'Content-Type: application/json' --data-binary "@$corpo")
  for tentativo in 1 2; do
    codice=$(printf 'header = "X-Figma-Token: %s"\n' "$token" |
      curl -sS -K - -D "$tmp/intestazioni" -o "$tmp/corpo" -w '%{http_code}' ${opzioni[@]+"${opzioni[@]}"} "$API$percorso")
    case "$codice" in
      2??) cat "$tmp/corpo"; rm -rf "$tmp"; return 0 ;;
      401|403) rm -rf "$tmp"; echo "❌ Token Figma: scaduto o senza permessi. $ISTRUZIONI" >&2; exit 3 ;;
      429)
        attesa=$(grep -i '^retry-after:' "$tmp/intestazioni" | tr -dc '0-9')
        attesa=${attesa:-1}
        if [ "$tentativo" = 1 ] && [ "$attesa" -le "$ATTESA_MASSIMA" ]; then sleep "$attesa"; continue; fi
        rm -rf "$tmp"; echo "⚠️ Limite dell'API di Figma: riprova tra $attesa secondi, o usa l'MCP." >&2; exit 4 ;;
      *) echo "❌ API di Figma: errore $codice su $percorso. $(head -c 300 "$tmp/corpo" 2>/dev/null)" >&2
        rm -rf "$tmp"; exit 1 ;;
    esac
  done
}

# Una riga per nodo e per ogni discendente; le misure sono vuote per chi non le ha (le pagine).
RIGHE='def righe($g): . as $n
  | ([$n.id, $n.type, ($n.name | gsub("[\t\n]"; " "))]
     + (if $n.absoluteBoundingBox then ($n.absoluteBoundingBox | [.x, .y, .width, .height] | map(round | tostring))
        else ["", "", "", ""] end)
     + [$g] | join("\t")),
    (($n.children // [])[] | righe($n.id));'

[ $# -ge 1 ] || uso
comando=$1; shift
case "$comando" in
  verifica)
    io=$(chiama GET /v1/me) || exit $?
    echo "✅ Token Figma: $(printf '%s' "$io" | jq -r '"\(.handle) (\(.email))"')"
    ;;

  struttura)
    [ $# -ge 1 ] || uso
    file=$1 nodo=${2:-} profondita=${3:-}
    if [ -z "$nodo" ]; then
      json=$(chiama GET "/v1/files/$file?depth=${profondita:-2}") || exit $?
      printf '%s' "$json" | jq -r "$RIGHE"' .document as $d | $d.children[] | righe($d.id)'
    else
      json=$(chiama GET "/v1/files/$file/nodes?ids=$nodo&depth=${profondita:-1}") || exit $?
      printf '%s' "$json" | jq -er --arg id "$nodo" "$RIGHE"' .nodes[$id].document | righe("-")' ||
        { echo "❌ Nodo $nodo non trovato in $file" >&2; exit 1; }
    fi
    ;;

  schermate)
    [ $# -ge 2 ] || uso
    file=$1; shift
    scala=1 nodi=()
    while [ $# -gt 0 ]; do
      case "$1" in
        --scala) scala=${2:-1}; shift 2 ;;
        *) nodi+=("$1"); shift ;;
      esac
    done
    [ ${#nodi[@]} -ge 1 ] || uso
    elenco=$(IFS=,; echo "${nodi[*]}")
    json=$(chiama GET "/v1/images/$file?ids=$elenco&format=png&scale=$scala") || exit $?
    mkdir -p "$CARTELLA/$file"
    esito=0
    for id in "${nodi[@]}"; do
      url=$(printf '%s' "$json" | jq -r --arg id "$id" '.images[$id] // empty')
      percorso="$CARTELLA/$file/${id//:/-}.png"
      if [ -z "$url" ]; then
        printf '%s\tNON RENDERIZZATO\n' "$id"
      elif curl -sS -o "$percorso" "$url"; then
        printf '%s\t%s\n' "$id" "$percorso"
      else
        printf '%s\tDOWNLOAD FALLITO\n' "$id"; esito=1
      fi
    done
    exit $esito
    ;;

  immagini)
    [ $# -ge 2 ] || uso
    file=$1 nodo=$2
    json=$(chiama GET "/v1/files/$file/nodes?ids=$nodo") || exit $?
    # id, nome e imageRef di ogni nodo sotto $nodo che ha un riempimento immagine.
    trovati=$(printf '%s' "$json" | jq -r --arg id "$nodo" '
      [.nodes[$id].document | .. | objects | select(.fills? | type == "array") | . as $n
        | .fills[] | select(.type == "IMAGE" and .imageRef) | [$n.id, ($n.name | gsub("[\t\n]"; " ")), .imageRef]]
      | unique_by(.[0]) | .[] | join("\t")')
    [ -n "$trovati" ] || { echo "Nessuna immagine sotto $nodo"; exit 0; }
    riempimenti=$(chiama GET "/v1/files/$file/images") || exit $?
    mkdir -p "$CARTELLA/$file"
    esito=0
    while IFS=$'\t' read -r id nome rif; do
      url=$(printf '%s' "$riempimenti" | jq -r --arg r "$rif" '.meta.images[$r] // empty')
      base="$CARTELLA/$file/${id//:/-}-immagine"
      if [ -n "$url" ] && curl -sS -o "$base.tmp" "$url"; then
        case "$(file -b --mime-type "$base.tmp")" in
          image/jpeg) estensione=jpg ;; image/png) estensione=png ;; image/webp) estensione=webp ;;
          image/gif) estensione=gif ;; *) estensione=bin ;;
        esac
        mv "$base.tmp" "$base.$estensione"
        printf '%s\t%s\t%s\n' "$id" "$nome" "$base.$estensione"
      else
        rm -f "$base.tmp"; printf '%s\t%s\tDOWNLOAD FALLITO\n' "$id" "$nome"; esito=1
      fi
    done <<< "$trovati"
    exit $esito
    ;;

  *) uso ;;
esac
