# Creatività: API di Figma, correzioni dai commenti, copy senza brief - Piano

> **Per chi esegue:** usa superpowers:subagent-driven-development o superpowers:executing-plans, **una sezione alla
> volta**: finita una sezione ci si ferma, si dice cosa è fatto e verificato, e si passa alla successiva solo con l'ok
> di Max. I passi hanno le caselle (`- [ ]`).

**Obiettivo:** le letture di Figma del plugin `creativita` passano dall'API REST, nasce il giro delle correzioni dai
commenti, e le ad senza copy passano sempre dai due subagenti con le regole del cliente.

**Architettura:** uno script bash nuovo, `plugins/creativita/scripts/figma.sh`, con un sottocomando per bisogno, che
chiama l'API con curl e legge il token dal Portachiavi. La skill lo usa per le letture e ripiega sull'MCP quando lo
script esce con un codice di errore. Le scritture restano a `use_figma` e `upload_assets`.

**Stack:** bash, curl, `/usr/bin/jq` (di serie da macOS 15), `security` del Portachiavi. Test come
`controlla.test.sh`: programmi finti nel PATH, nessuna rete.

**Design:** `2026-11-03-creativita-api-figma-design.md` [[2026-11-03-creativita-api-figma-design]], nella stessa
cartella di questo piano. Chi esegue legge tutti e due.

**Repo:** `codice/otto-claude/worktrees/creativita`, ramo `feat/creativita`. Si parte solo dopo il commit delle
modifiche aperte su `SKILL.md`, `agents/format-concept.md` e sul design generale, e su quella base.

## Vincoli globali

- Il token **non si stampa mai** e non passa negli argomenti di un comando (si vedrebbe in `ps`): arriva a curl da
  stdin con `-K -`, riga `header = "X-Figma-Token: <token>"`.
- Voce del Portachiavi: servizio `figma-token`, account `$USER`. Lettura: `security find-generic-password -s figma-token -w`.
- Scope del token: `file_content:read`, `file_comments:read`, `file_comments:write`, `current_user:read`; scadenza
  massima 90 giorni.
- Base dell'API: `https://api.figma.com`. Tutti i testi a schermo in italiano, senza trattino lungo.
- Codici di uscita di `figma.sh`: `0` ok, `1` errore generico, `2` uso sbagliato, `3` token mancante, scaduto o senza
  permessi, `4` limite dell'API anche dopo l'attesa. Con `3` e `4` la skill ripiega sull'MCP.
- Le immagini scaricate vanno in `${FIGMA_CARTELLA:-${TMPDIR:-/tmp}/creativita-figma}/<file>/`, nome
  `<id del nodo con : sostituito da ->.png`.

## Punti da controllare in revisione

1. **Token con spazi o a capo finale** (copiato male): lo script lo ripulisce prima di usarlo; se resta vuoto esce 3.
2. **Pagina con molti frame** (il B10 ha 16 righe): `schermate` deve fare una sola chiamata `GET /v1/images` con tutti
   gli id, non una per nodo.
3. **Commento su un livello dentro il frame** (un testo, non il frame): va attribuito al frame del lotto che lo contiene.
4. **Thread già sistemato e poi riaperto** con una nuova risposta di un collega: torna fra quelli da fare.
5. **`Retry-After` molto lungo** (oltre 60 secondi): niente attesa, esce 4 subito.

Ognuno ha il suo test nella sezione che possiede il codice.

---

## Sezione 1: verifiche preliminari (con Max) - FATTA il 03/11

Esiti nel design, sezione «Verificato il 03/11». Tutto passa: niente regola di permesso, niente attesa dopo le
scritture, reazione `:white_check_mark:` confermata. In più: corretto il filtro dei thread già sistemati.

Nessun codice nel repo. Serve a sapere se il disegno regge prima di scriverlo.

- [ ] **1.1 Token.** Max crea il token su figma.com (Impostazioni, Sicurezza, Personal access token, 90 giorni, i
  quattro scope), lo copia e **poi** lancia:

  ```bash
  security add-generic-password -U -s figma-token -a "$USER" -w "$(pbpaste)"
  ```

- [ ] **1.2 Portachiavi in auto mode.** Claude lancia una riga che legge la voce e chiama `/v1/me` senza stampare il
  token:

  ```bash
  printf 'header = "X-Figma-Token: %s"\n' "$(security find-generic-password -s figma-token -w)" | curl -sS -K - https://api.figma.com/v1/me | /usr/bin/jq -r .handle
  ```

  Atteso: `Massimo`. Se il classificatore la blocca, si chiede a Max una regola di permesso per
  `plugins/creativita/scripts/figma.sh` e la prova si ripete dopo la Sezione 2, lanciando lo script.
- [ ] **1.3 Lettura dopo scrittura.** Con l'MCP si cambia un testo in un frame di prova creato apposta in una pagina
  indicata da Max (non B8, non B10). Subito dopo si chiede il render con `GET /v1/images` e si guarda se il testo è
  quello nuovo; se no, si riprova dopo 5 e 15 secondi. Si annota il ritardo nel design, sezione «Da verificare».
- [ ] **1.4 Reazione.** Sullo stesso frame si mette un commento di prova, si prova
  `POST /v1/files/:key/comments/:id/reactions` con `{"emoji":":white_check_mark:"}` e si controlla che su Figma compaia
  ✅. Se il formato è un altro, si corregge nel design. Poi si cancellano il commento di prova e il frame.

Fine sezione: resoconto a Max con i tre esiti.

## Sezione 2: `figma.sh`, letture - FATTA il 03/11 (dcefce3)

**File:**
- Crea: `plugins/creativita/scripts/figma.sh`
- Crea: `plugins/creativita/scripts/figma.test.sh`

**Interfacce prodotte:**
- `figma.sh verifica` → stampa `✅ Token Figma: <handle> (<email>)`, esce 0. Token assente: `❌ Token Figma: manca.`
  più le istruzioni del passo 1.1, esce 3. Risposta 401 o 403: `❌ Token Figma: scaduto o senza permessi.` più le
  istruzioni, esce 3.
- `figma.sh struttura <file> [nodo] [profondità]` → senza nodo `GET /v1/files/<file>?depth=<profondità, default 2>`;
  con nodo `GET /v1/files/<file>/nodes?ids=<nodo>&depth=<profondità, default 1>`. Stampa una riga per nodo, separata
  da tab: `id tipo nome x y larghezza altezza id_genitore` (x, y, misure da `absoluteBoundingBox`, arrotondate; vuote
  per le pagine).
- `figma.sh schermate <file> <nodo>... [--scala N]` → una sola `GET /v1/images/<file>?ids=<a,b,c>&format=png&scale=<N, default 1>`,
  poi scarica ogni URL. Stampa `id percorso` per riga. Un id con URL `null` stampa `id NON RENDERIZZATO` e non fa
  fallire gli altri.
- `figma.sh immagini <file> <nodo>` → `GET .../nodes?ids=<nodo>` senza profondità, raccoglie i nodi con un riempimento
  `IMAGE` (`imageRef`), poi `GET /v1/files/<file>/images` e scarica gli URL di quegli `imageRef`. Stampa
  `id nome percorso`.
- Funzione interna `chiama <metodo> <percorso> [file del corpo]` usata anche dalla Sezione 3: legge il token, gestisce
  401/403 (esce 3) e 429 (attende `Retry-After` se è al massimo 60 secondi e riprova una volta; altrimenti esce 4),
  scrive il corpo della risposta su stdout.

Chiamata a curl, fissa perché i test la imitano:
`curl -sS -K - -D <file intestazioni> -o <file corpo> -w '%{http_code}' [-X POST -H 'Content-Type: application/json' --data-binary @<file>] <url>`.
Download delle immagini senza token: `curl -sS -o <percorso> <url>`.

- [ ] **2.1 Test che falliscono.** `figma.test.sh` mette nel PATH un `curl` finto (legge stdin, lo salva in un file
  per i controlli, risponde con JSON fissi scelti dall'URL e dalla variabile `FINTO_FIGMA`) e un `security` finto
  (stampa `tok-segreto-123` o esce 44 con `FINTO_TOKEN=assente`). Casi:
  - `verifica` con token: uscita contiene `✅ Token Figma: Massimo`, codice 0;
  - `verifica` con `FINTO_TOKEN=assente`: contiene `❌ Token Figma: manca`, codice 3;
  - `verifica` con `FINTO_FIGMA=403`: contiene `scaduto o senza permessi`, codice 3;
  - token mai a schermo: nessuna uscita dei casi sopra contiene `tok-segreto-123`;
  - token mai negli argomenti: il `curl` finto registra `$*` e non deve contenere `tok-segreto-123`, mentre lo stdin
    salvato contiene `X-Figma-Token: tok-segreto-123`;
  - token con spazi e a capo (`security` finto stampa `  tok-segreto-123  \n`): lo stdin contiene
    `X-Figma-Token: tok-segreto-123"` senza spazi;
  - `struttura LRhz 53:671`: una riga che comincia con `53:700\tFRAME\tB10_ 3.11.2026 - C1 - 9:16\t4200\t0\t1080\t1920\t53:671`;
  - `schermate LRhz 1:1 1:2 1:3`: il `curl` finto riceve **una** sola chiamata a `/v1/images/` con `ids=1:1,1:2,1:3`, e
    l'uscita ha tre righe `id percorso` con file esistenti;
  - `schermate` con un id che torna `null`: riga `1:3 NON RENDERIZZATO`, codice 0;
  - `immagini LRhz 5:1`: scarica solo gli `imageRef` dei nodi sotto `5:1`, una riga per nodo;
  - `FINTO_FIGMA=429` con `Retry-After: 1`: due chiamate, la seconda ok, codice 0;
  - `FINTO_FIGMA=429lungo` con `Retry-After: 120`: una sola chiamata, codice 4, in meno di 5 secondi;
  - uso sbagliato (`figma.sh boh`): codice 2.
- [ ] **2.2** `bash plugins/creativita/scripts/figma.test.sh`: fallisce perché `figma.sh` non esiste.
- [ ] **2.3 Scrivi `figma.sh`** con i sottocomandi sopra, commenti in testa come `controlla.sh` (cosa fa, chi lo
  lancia, che il token non si stampa).
- [ ] **2.4** `bash plugins/creativita/scripts/figma.test.sh`: stampa `ok`, codice 0.
- [ ] **2.5 Prova vera, solo letture:** `figma.sh verifica`, poi `figma.sh struttura LRhzTaDLREM1sSKAJKGoMV 53:671` e
  `figma.sh schermate` su due frame del B10. Atteso: righe sensate e due PNG che si aprono. Niente scritture.
- [ ] **2.6 Commit** (se Max l'ha autorizzato): `feat(creativita): letture di Figma via API`.

Fine sezione: resoconto e stop.

## Sezione 3: `figma.sh`, commenti - FATTA il 03/11, senza la prova vera 3.5 (Max: non ora)

**File:** modifica `plugins/creativita/scripts/figma.sh` e `figma.test.sh`.

**Interfacce:**
- Usa `chiama` e `struttura` della Sezione 2.
- `figma.sh commenti <file> <pagina>` → `GET /v1/me`, `GET /v1/files/<file>/comments?as_md=true`, i frame di primo
  livello della pagina (`struttura <file> <pagina> 1`) e, per i nodi dei commenti, `GET .../nodes?ids=<tutti>&depth=0`
  in una chiamata. Tiene i commenti di primo livello (`parent_id` vuoto) senza `resolved_at`. Ne scarta quelli il cui
  ultimo messaggio del thread (per `created_at`) è una risposta (`parent_id` pieno) dell'utente di `/v1/me` che
  comincia con `Fatto:` o `Non fatto:`. Attribuisce il frame:
  il frame di primo livello della pagina che contiene il centro del riquadro del nodo del commento. Stampa
  `id_frame nome_frame id_commento autore data testo` (testo su una riga, a capo sostituiti da ` / `). I commenti senza
  `node_id` o fuori da ogni frame della pagina vanno in fondo, con `id_frame` = `-` e nome `NON ATTRIBUITO`.
- `figma.sh rispondi <file> <commento> <testo>` → `POST /v1/files/<file>/comments` con
  `{"message": <testo>, "comment_id": <commento>}` costruito con jq. Stampa `✅ risposto a <commento>`.
- `figma.sh reazione <file> <commento>` → `POST /v1/files/<file>/comments/<commento>/reactions` con
  `{"emoji":":white_check_mark:"}` (o il formato trovato in 1.4). Stampa `✅ reazione su <commento>`.

- [ ] **3.1 Test che falliscono**, con JSON finti di commenti:
  - commento aperto su un frame: compare con il nome del frame;
  - commento su un testo dentro il frame `C2 - 1:1` (nodo figlio con riquadro dentro il frame): attribuito a
    `C2 - 1:1`;
  - commento risolto: non compare;
  - risposta (`parent_id` pieno): non compare come riga a sé;
  - thread la cui ultima risposta è di `Massimo` (id di `/v1/me`) e comincia con `Fatto:`: non compare;
  - commento radice scritto da `Massimo` senza risposte: compare;
  - thread con una risposta di `Massimo` che non comincia con `Fatto:` né `Non fatto:`: compare;
  - lo stesso thread con una risposta successiva di un collega: compare;
  - commento senza `node_id`: riga con `NON ATTRIBUITO`;
  - `rispondi` con un testo con virgolette e accenti: il corpo POST ricevuto dal `curl` finto è JSON valido con
    `comment_id` giusto;
  - `reazione`: corpo con l'emoji.
- [ ] **3.2** Test: falliscono sui casi nuovi.
- [ ] **3.3** Implementa i tre sottocomandi.
- [ ] **3.4** Test: `ok`.
- [ ] **3.5 Prova vera:** `figma.sh commenti` sulla pagina di prova della Sezione 1 con un commento messo da Max;
  `rispondi` e `reazione` su quel commento; Max guarda su Figma. Poi si pulisce.
- [ ] **3.6 Commit:** `feat(creativita): commenti di Figma via API`.

Fine sezione: resoconto e stop.

## Sezione 4: configurazione - FATTA il 03/11

**File:** modifica `plugins/creativita/scripts/controlla.sh` e `controlla.test.sh`.

- [ ] **4.1 Test che falliscono** in `controlla.test.sh`: con un `figma.sh` raggiungibile e token presente, l'uscita di
  `configura` contiene `✅ Token Figma`; con token assente contiene `❌ Token Figma` e
  `security add-generic-password -U -s figma-token`; la riga del token **non** rende bloccante il resto (gli altri ✅
  restano).
- [ ] **4.2** Test: falliscono.
- [ ] **4.3** In `controlla.sh` una funzione `riga_token_figma` che lancia `bash "$QUI/figma.sh" verifica` dentro
  `entro`, e la chiama in `configura` dopo `riga_figma`. Nel messaggio ❌ aggiunge: «Senza token il giro funziona lo
  stesso, con più chiamate all'MCP di Figma».
- [ ] **4.4** Test: `ok` per `controlla.test.sh` e `figma.test.sh`.
- [ ] **4.5 Commit:** `feat(creativita): il token di Figma nella configurazione guidata`.

Fine sezione: resoconto e stop.

## Sezione 5: skill, subagenti e design - FATTA il 03/11

**File:** `plugins/creativita/skills/creativita/SKILL.md`, `plugins/creativita/agents/visual-testi.md`,
`plugins/creativita/agents/format-concept.md`, `docs/superpowers/specs/2026-11-03-creativita-design.md`. Niente test
automatici: la prova è la Sezione 6.

- [ ] **5.1 SKILL.md, una regola sola su API e MCP** (nuova sezione prima di «Il giro», titolo «Letture e scritture su
  Figma»): le letture si fanno con `figma.sh` (`${CLAUDE_PLUGIN_ROOT}/scripts/figma.sh`), le scritture con l'MCP; se
  lo script esce 3 o 4 si usa l'MCP per quella lettura e lo si scrive nel resoconto; `create_session` resta prima di
  ogni scrittura MCP. Tabella breve: `get_metadata` → `struttura`, `get_screenshot` → `schermate` (tutti i nodi
  insieme), reference del brand kit → `immagini`.
- [ ] **5.2 SKILL.md, passo 2:** struttura e linee guida del brand kit con `struttura` e una sola `schermate`; foto e
  schermate del prodotto per le reference con `immagini` sul nodo «Asset · 03 Immagini» (o quello giusto).
- [ ] **5.3 SKILL.md, passo 6:** ultimo lotto e `y` della prima riga libera con `struttura`; controllo finale con una
  sola `schermate` su tutti i frame del giro. Se la Sezione 1 ha trovato un ritardo di lettura dopo scrittura, qui
  va l'attesa misurata.
- [ ] **5.4 SKILL.md, ad senza copy:** il passo 3 vale per la statica **e** per le ad del brief senza testi; i
  subagenti girano sempre, anche per una sola ad; a tutti e due si passa il **testo intero** di istruzioni e skill del
  cliente su creatività, copy, tono e visual (scelta dei file e taglio dei file lunghi come nel design); prima di
  Figma i copy si controllano contro le regole e si correggono. In «Ingresso dal brief»: copy a metà, si scrivono solo
  i pezzi mancanti; brief senza copy, concept e note vincolanti; copy uno per variante.
- [ ] **5.5 SKILL.md, nuova sezione «Il giro delle correzioni»** con i passi 1-5 del design, le regole di
  propagazione (contenuto sui due formati della variante, posizione solo sul frame, mai sulle altre varianti, nel dubbio
  solo il frame) e la frase del resoconto. Nella `description` del frontmatter aggiungere il trigger «sistema i
  commenti del lotto».
- [ ] **5.5b SKILL.md, pagine del file:**
  - nel passo 6, la regola delle tre pagine (Brand kit, Foto e immagini, una per brief);
  - un passo finale prima del resoconto: le scene del brief vanno in «Foto e immagini» con lo stesso `imageHash`, una
    riga per brief, la più recente in alto. Se la pagina non c'è, si crea;
  - nel passo 2, il brand kit si arricchisce dal sito del cliente nel riquadro «Da verificare», che non si usa finché
    il team non lo svuota;
  - le stesse regole nel design generale, sezione «Il brand kit e i file su Figma».
- [ ] **5.6 visual-testi.md:** in «Cosa restituisci», per ogni testo la regola o skill del cliente seguita, o «il
  cliente non ha regole sui copy»; con un brief, solo i pezzi mancanti e coerenti con quelli dati.
- [ ] **5.7 format-concept.md:** con un brief, concept e note del brief sono vincolanti: le varianti sono esecuzioni
  dentro quel concept.
- [ ] **5.8 Design generale, «Vincoli»:** limiti MCP (200/giorno, 10/min) e API (15/min file e render, 50/min commenti,
  piano Pro), token personale a 90 giorni; rimando al design di questa estensione.
- [ ] **5.9** `bash plugins/creativita/scripts/figma.test.sh && bash plugins/creativita/scripts/controlla.test.sh`:
  tutti e due `ok`.
- [ ] **5.10 Commit:** `feat(creativita): letture via API, giro delle correzioni e copy senza brief nella skill`.

Fine sezione: resoconto e stop.

## Sezione 6: prova sul campo

- [ ] **6.1 Giro con statica senza copy**, su una statica e una pagina scelte da Max: si controlla che partano i due
  subagenti, che i copy abbiano le regole del cliente accanto, e si contano le chiamate MCP del giro (atteso: solo
  `create_session`, `use_figma`, `upload_assets`). Alla fine, le scene sono anche in «Foto e immagini».
- [ ] **6.2 Giro delle correzioni** sullo stesso lotto, dopo che Max ha lasciato due o tre commenti (uno di testo, uno
  di posizione, uno sulla scena): risposte «Fatto» e ✅ su Figma, propagazione come da regole.
- [ ] **6.3** Resoconto finale a Max e aggiornamento del `task.md` del progetto.
