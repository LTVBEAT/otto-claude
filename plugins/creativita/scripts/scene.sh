#!/bin/bash
# Lancia le scene di un giro su Higgsfield. Lo lancia Claude, su istruzione della skill:
#   scene.sh costo <cartella> [--formato 9:16|1:1]            stima i crediti di tutte le scene della cartella
#   scene.sh genera <cartella> [nome...] [--formato 9:16|1:1]  genera e scarica: una riga «nome<TAB>percorso»
# Nella cartella, per ogni scena: <nome>.txt con il prompt (in inglese, comincia con «Paid social static ad») e, se
# servono, <nome>.ref con le reference, un percorso per riga e nell'ordine (prima la statica o la reference del brief).
# L'immagine finisce in <nome>.png. Senza nomi si generano solo le scene che non hanno ancora il PNG.
# Modello del giro (Max, 03/11): gpt_image_2_5 sunburst, xhigh, 1k. Al massimo 4 scene insieme: il piano pro rifiuta
# la quinta con rate_limit_reached, senza spendere, e qui si rilancia da sola. nsfw ed errori non si rilanciano.
# Uscite: 0 tutte fatte, 1 almeno una non fatta (NSFW o ERRORE nella sua riga), 2 uso sbagliato.
set -u

MODELLO=(gpt_image_2_5 --variant sunburst --quality xhigh --resolution 1k)
INSIEME=4
TENTATIVI=5
ATTESA=${SCENE_ATTESA:-20}

uso() { sed -n '2,9p' "$0" | sed 's/^# *//' >&2; exit 2; }

[ $# -ge 2 ] || uso
comando=$1 cartella=${2%/}; shift 2
[ -d "$cartella" ] || { echo "❌ Cartella $cartella non trovata" >&2; exit 2; }
formato=9:16 nomi=()
while [ $# -gt 0 ]; do
  case "$1" in
    --formato) formato=${2:-}; shift 2 ;;
    *) nomi+=("${1%.txt}"); shift ;;
  esac
done
case "$formato" in 9:16|1:1) ;; *) echo "❌ Formato $formato: solo 9:16 o 1:1" >&2; exit 2 ;; esac

tutte=()
for f in "$cartella"/*.txt; do [ -f "$f" ] && tutte+=("$(basename "$f" .txt)"); done
[ ${#tutte[@]} -ge 1 ] || { echo "❌ Nessun prompt (<nome>.txt) in $cartella" >&2; exit 2; }

# riferimenti <nome>: gli argomenti --image-references dal file .ref, righe vuote saltate.
riferimenti() {
  local riga
  [ -f "$cartella/$1.ref" ] || return 0
  while IFS= read -r riga || [ -n "$riga" ]; do
    [ -n "$riga" ] && printf '%s\0' --image-references "$riga"
  done < "$cartella/$1.ref"
}

case "$comando" in
  costo)
    totale=0
    for n in "${tutte[@]}"; do
      crediti=$(higgsfield generate cost "${MODELLO[@]}" --aspect_ratio "$formato" --prompt "$(cat "$cartella/$n.txt")" \
        --json 2>&1 | jq -r '.credits // empty' 2>/dev/null)
      [ -n "$crediti" ] || { echo "❌ Stima del costo non riuscita per $n" >&2; exit 1; }
      totale=$(echo "$totale + $crediti" | bc)
    done
    echo "${#tutte[@]} scene, $(echo "$totale" | sed -E 's/\.0+$//; s/^\./0./') crediti"
    ;;

  genera)
    if [ ${#nomi[@]} -eq 0 ]; then
      for n in "${tutte[@]}"; do
        if [ -s "$cartella/$n.png" ]; then printf '%s\t%s (già fatta)\n' "$n" "$cartella/$n.png"; else nomi+=("$n"); fi
      done
    fi
    [ ${#nomi[@]} -ge 1 ] || exit 0

    # una <nome>: genera, rilancia sui rifiuti per il limite, scarica; scrive l'esito in <nome>.esito.
    una() {
      local n=$1 tentativo risposta stato url rif=()
      local esito="$cartella/$n.esito"
      if [ ! -f "$cartella/$n.txt" ]; then printf '%s\tERRORE manca %s.txt\n' "$n" "$n" > "$esito"; return; fi
      if ! head -c 200 "$cartella/$n.txt" | grep -qi '^ *Paid social static ad'; then
        printf '%s\tERRORE il prompt non comincia con «Paid social static ad»\n' "$n" > "$esito"; return
      fi
      while IFS= read -r -d '' a; do rif+=("$a"); done < <(riferimenti "$n")
      for tentativo in $(seq "$TENTATIVI"); do
        higgsfield generate create "${MODELLO[@]}" --aspect_ratio "$formato" --prompt "$(cat "$cartella/$n.txt")" \
          ${rif[@]+"${rif[@]}"} --wait --wait-timeout 15m --json > "$cartella/$n.json" 2> "$cartella/$n.err"
        grep -qi 'rate_limit' "$cartella/$n.err" "$cartella/$n.json" || break
        sleep "$ATTESA"
      done
      risposta=$(jq -c 'if type == "array" then .[0] else . end' "$cartella/$n.json" 2>/dev/null)
      stato=$(printf '%s' "$risposta" | jq -r '.status // empty' 2>/dev/null)
      url=$(printf '%s' "$risposta" | jq -r '.result_url // empty' 2>/dev/null)
      if [ "$stato" = completed ] && [ -n "$url" ] && curl -sS -o "$cartella/$n.png" "$url" && [ -s "$cartella/$n.png" ]; then
        printf '%s\t%s\n' "$n" "$cartella/$n.png" > "$esito"
      elif [ "$stato" = nsfw ]; then
        printf '%s\tNSFW\n' "$n" > "$esito"
      else
        printf '%s\tERRORE %s\n' "$n" "$(tr '\n' ' ' < "$cartella/$n.err" | sed -E 's/^ *Error: *//; s/ *$//' | head -c 200)" \
          > "$esito"
      fi
    }

    for n in "${nomi[@]}"; do
      rm -f "$cartella/$n.esito"
      while [ "$(jobs -rp | wc -l)" -ge "$INSIEME" ]; do sleep 0.2; done
      una "$n" &
    done
    wait
    esito=0
    for n in "${nomi[@]}"; do
      cat "$cartella/$n.esito"
      grep -q "$(printf '\t')\(NSFW\|ERRORE\)" "$cartella/$n.esito" && esito=1
      rm -f "$cartella/$n.esito"
    done
    exit $esito
    ;;

  *) uso ;;
esac
