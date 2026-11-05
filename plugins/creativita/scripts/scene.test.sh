#!/bin/bash
# Prova il lancio delle scene: bash plugins/creativita/scripts/scene.test.sh
# higgsfield e curl sono finti, nel PATH: nessun credito speso.
set -u
QUI=$(cd "$(dirname "$0")" && pwd)
BASE=$(mktemp -d)
ERRORI=0
mkdir -p "$BASE/bin"

# La higgsfield finta: registra gli argomenti, conta quante generazioni girano insieme, e risponde in base al
# nome della scena scritto nel prompt («SCENA=<nome>»).
cat > "$BASE/bin/higgsfield" <<'EOF'
#!/bin/bash
echo "$*" >> "$FINTO/argomenti"
[ "$1 $2" = "generate cost" ] && { echo '{"credits": 2.5}'; exit 0; }
[ "$1 $2" = "generate create" ] || exit 9
nome=$(printf '%s' "$*" | sed -E 's/.*SCENA=([a-z0-9-]+).*/\1/')
until mkdir "$FINTO/lucchetto" 2>/dev/null; do sleep 0.01; done
n=$(( $(cat "$FINTO/in-corso" 2>/dev/null || echo 0) + 1 )); echo $n > "$FINTO/in-corso"
[ $n -gt "$(cat "$FINTO/massimo" 2>/dev/null || echo 0)" ] && echo $n > "$FINTO/massimo"
rmdir "$FINTO/lucchetto"
sleep 0.3
until mkdir "$FINTO/lucchetto" 2>/dev/null; do sleep 0.01; done
echo $(( $(cat "$FINTO/in-corso") - 1 )) > "$FINTO/in-corso"; rmdir "$FINTO/lucchetto"
case "$nome" in
  limite) if [ ! -f "$FINTO/gia-limite" ]; then touch "$FINTO/gia-limite"
            echo 'Error: rate_limit_reached: too many concurrent jobs' >&2; exit 1; fi ;;
  nsfw) echo '{"id":"j-nsfw","status":"nsfw","result_url":null}'; exit 0 ;;
  rotta) echo 'Error: internal server error' >&2; exit 1 ;;
esac
echo "[{\"id\":\"j-$nome\",\"status\":\"completed\",\"result_url\":\"https://cdn.finto/$nome.png\"}]"
EOF
cat > "$BASE/bin/curl" <<'EOF'
#!/bin/bash
uscita=''; while [ $# -gt 0 ]; do case "$1" in -o) uscita=$2; shift 2 ;; *) shift ;; esac; done
echo 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==' | base64 -D > "$uscita"
EOF
chmod +x "$BASE/bin/higgsfield" "$BASE/bin/curl"

scene() { # variabili (NOME=valore), poi gli argomenti di scene.sh
  local vari=()
  while [ $# -gt 0 ] && [[ "$1" == *=* ]]; do vari+=("$1"); shift; done
  : > "$BASE/argomenti"; rm -f "$BASE/in-corso" "$BASE/massimo" "$BASE/gia-limite"
  env PATH="$BASE/bin:/usr/bin:/bin" FINTO="$BASE" SCENE_ATTESA=0 ${vari[@]+"${vari[@]}"} bash "$QUI/scene.sh" "$@" 2>&1
}
prompt() { echo "Paid social static ad image (Meta, 9:16) for Learnn. SCENA=$2" > "$1/$2.txt"; }
contiene() { printf '%s' "$2" | grep -qF -- "$3" || { echo "FAIL $1: manca «$3»"; ERRORI=1; }; }
manca() { printf '%s' "$2" | grep -qF -- "$3" && { echo "FAIL $1: non doveva esserci «$3»"; ERRORI=1; }; }
codice() { [ "$2" = "$3" ] || { echo "FAIL $1: codice $2, atteso $3"; ERRORI=1; }; }
TAB=$(printf '\t')

# costo: una stima per scena, con i parametri del giro, e il totale.
G="$BASE/giro1"; mkdir -p "$G"; prompt "$G" c1; prompt "$G" c2
uscita=$(scene costo "$G"); c=$?
codice "costo" $c 0
contiene "costo" "$uscita" "2 scene, 5 crediti"
manca "costo, nessuna generazione" "$(cat "$BASE/argomenti")" "generate create"
contiene "costo, parametri" "$(cat "$BASE/argomenti")" "generate cost gpt_image_2_5 --variant sunburst --quality xhigh --resolution 1k --aspect_ratio 9:16"

# genera: reference nell'ordine del .ref, PNG scaricato, una riga per scena.
printf '%s\n' "$BASE/statica.png" "$BASE/app.png" > "$G/c1.ref"
uscita=$(scene genera "$G"); c=$?
codice "genera" $c 0
contiene "genera" "$uscita" "c1${TAB}$G/c1.png"
contiene "genera" "$uscita" "c2${TAB}$G/c2.png"
[ -s "$G/c1.png" ] || { echo "FAIL genera: manca il PNG di c1"; ERRORI=1; }
contiene "genera, reference in ordine" "$(cat "$BASE/argomenti")" "--image-references $BASE/statica.png --image-references $BASE/app.png"
contiene "genera, attesa" "$(cat "$BASE/argomenti")" "--wait"

# Una scena già scaricata non si rilancia, a meno di chiederla per nome.
uscita=$(scene genera "$G")
manca "già fatta" "$(cat "$BASE/argomenti")" "generate create"
contiene "già fatta" "$uscita" "c1${TAB}$G/c1.png (già fatta)"
scene genera "$G" c2 >/dev/null
[ "$(grep -c 'generate create' "$BASE/argomenti")" = 1 ] || { echo "FAIL per nome: doveva rifare solo c2"; ERRORI=1; }

# 1:1 dal parametro.
G2="$BASE/giro2"; mkdir -p "$G2"; prompt "$G2" q1
scene genera "$G2" --formato 1:1 >/dev/null
contiene "formato" "$(cat "$BASE/argomenti")" "--aspect_ratio 1:1"

# Al massimo 4 insieme, anche con 6 scene.
G3="$BASE/giro3"; mkdir -p "$G3"; for n in a1 a2 a3 a4 a5 a6; do prompt "$G3" $n; done
uscita=$(scene genera "$G3"); c=$?
codice "sei scene" $c 0
[ "$(cat "$BASE/massimo")" -le 4 ] || { echo "FAIL sei scene: $(cat "$BASE/massimo") insieme"; ERRORI=1; }
[ "$(printf '%s\n' "$uscita" | grep -c '\.png$')" = 6 ] || { echo "FAIL sei scene: non sono 6 PNG"; ERRORI=1; }

# rate_limit_reached non spende: si rilancia da sola. nsfw e un errore si dicono, e l'uscita è 1.
G4="$BASE/giro4"; mkdir -p "$G4"; prompt "$G4" limite; prompt "$G4" nsfw; prompt "$G4" rotta
uscita=$(scene genera "$G4"); c=$?
codice "difficili" $c 1
contiene "limite rilanciato" "$uscita" "limite${TAB}$G4/limite.png"
contiene "nsfw" "$uscita" "nsfw${TAB}NSFW"
contiene "errore" "$uscita" "rotta${TAB}ERRORE internal server error"
[ "$(grep -c 'SCENA=rotta' "$BASE/argomenti")" = 1 ] || { echo "FAIL errore: rilanciata da sola"; ERRORI=1; }

# Un prompt che non dice che è un'ad non parte.
G5="$BASE/giro5"; mkdir -p "$G5"; echo "A cat on a sofa SCENA=gatto" > "$G5/gatto.txt"
uscita=$(scene genera "$G5"); c=$?
codice "non è un'ad" $c 1
contiene "non è un'ad" "$uscita" "gatto${TAB}ERRORE il prompt non comincia con «Paid social static ad»"
manca "non è un'ad" "$(cat "$BASE/argomenti")" "generate create"

# Uso sbagliato.
scene boh >/dev/null; codice "uso sbagliato" $? 2
scene genera "$BASE/non-esiste" >/dev/null; codice "cartella mancante" $? 2

rm -rf "$BASE"
[ $ERRORI -eq 0 ] && echo "ok"
exit $ERRORI
