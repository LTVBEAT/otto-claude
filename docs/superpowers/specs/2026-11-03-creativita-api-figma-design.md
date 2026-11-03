# Creatività: API di Figma, correzioni dai commenti, copy senza brief

Design del 03/11/2026 per il plugin `creativita` (ramo `feat/creativita`). Si aggiunge al design generale
`docs/superpowers/specs/2026-11-03-creativita-design.md` del ramo, non lo sostituisce.

## Perché

- L'MCP di Figma ha un tetto: con il posto Full sul piano Pro di Beat Performance sono **200 chiamate al giorno e 10 al
  minuto**, e un giro con più ad e varianti lo consuma in fretta. Il 03/11 il tetto è stato raggiunto.
- L'API REST di Figma ha solo limiti al minuto, niente tetto giornaliero: lettura del file e render 15/min, commenti
  50/min (piano Pro, posto Full). Il limite conta il piano del file, non quello della persona.
- L'API legge e scrive i **commenti**, l'MCP no. Max li vuole per le correzioni: il team commenta i frame su Figma e
  Claude le applica. «È comodo».
- Max, 03/11: quando l'ad arriva **senza copy** (una statica, o un brief senza testi), i due subagenti devono fare il
  loro lavoro per intero: controllo del visual e ragionamento sui copy, con i copy scritti seguendo le istruzioni e le
  skill del cliente.

## Obiettivi

1. Tutte le **letture** di Figma passano dall'API quando la persona ha il token: struttura del file e delle pagine,
   schermate di sezioni e frame, immagini originali del brand kit. All'MCP restano solo le **scritture**.
2. Un **giro delle correzioni**: Claude legge i commenti aperti sui frame di un lotto, li applica, risponde a ognuno.
3. Ad senza copy: i subagenti girano sempre e i copy seguono alla lettera regole e skill del cliente.

## Non obiettivi

- Scrivere nodi via API: l'API REST non crea frame, testi o immagini. Montaggio e caricamento delle scene restano a
  `use_figma` e `upload_assets`.
- Composio per Figma: le sue azioni sono le stesse dell'API REST, senza scrittura di nodi. In più avrebbe bisogno di una
  connessione Figma su Composio che oggi non c'è, metterebbe JSON lunghi nel contesto e sarebbe legato all'account di
  Max, mentre il plugin è per il team.
- Webhook sui commenti (servirebbe un server che li riceve): le correzioni partono quando la persona lo chiede.

## Anti-obiettivi

- Il token di Figma stampato a schermo, scritto in un file o passato in una riga di comando visibile.
- Commenti di altri cancellati, o correzioni applicate a frame sbagliati.
- Un commento già sistemato rifatto a ogni giro.
- Copy inventati «a sentimento» quando il cliente ha regole e skill scritte.
- Il giro che si blocca perché manca il token: senza token si va con l'MCP come oggi.

## Vincoli

- **Token personale Figma (PAT)**, uno per persona, con scadenza massima 90 giorni. Scope: `file_content:read`,
  `file_comments:read`, `file_comments:write`, `current_user:read`. Vede solo i file che la persona vede già.
- Il token sta nel **Portachiavi** del Mac di ognuno, voce `figma-token`. Lo legge solo lo script, con
  `security find-generic-password -s figma-token -w`, e lo passa a curl senza stamparlo.
- L'API non permette di **risolvere** un commento: si risponde e si mette una reazione, la persona lo risolve su Figma.
- Il commento ha `resolved_at` (se risolto), `parent_id` (se è una risposta), `user`, `order_id` e `client_meta`, che
  è una posizione assoluta (x, y) oppure relativa a un nodo (`node_id` più `node_offset`).

## Lo script `scripts/figma.sh`

Un comando per ogni bisogno del giro. Stampa poco e in chiaro; le immagini le scarica in una cartella temporanea e ne
stampa i percorsi.

| Comando | Endpoint | Sostituisce nel giro |
|---|---|---|
| `figma.sh struttura <file> [nodo] [profondità]` | `GET /v1/files/:key?depth=` o `/nodes?ids=` | `get_metadata` |
| `figma.sh schermate <file> <nodo...> [scala]` | `GET /v1/images/:key?ids=a,b,c&format=png` | `get_screenshot`, **tutti i nodi in una chiamata** |
| `figma.sh immagini <file>` | `GET /v1/files/:key/images` | non c'era: foto e schermate originali del brand kit per le `--image-references` |
| `figma.sh commenti <file> <pagina>` | `GET /v1/files/:key/comments` più la struttura della pagina | non c'era |
| `figma.sh rispondi <file> <commento> <testo>` | `POST /v1/files/:key/comments` con `comment_id` | non c'era |
| `figma.sh reazione <file> <commento>` | `POST .../comments/:id/reactions` (✅) | non c'era |
| `figma.sh verifica` | `GET /v1/me` | controllo del token |

- **429:** legge `Retry-After`, aspetta e riprova una volta; se fallisce ancora, lo dice e Claude passa all'MCP per
  quella lettura.
- **403 o token mancante:** una riga sola con l'azione da fare («crea il token e salvalo», vedi configurazione), e
  Claude continua con l'MCP.
- La struttura stampa per ogni nodo: id, nome, tipo, x, y, larghezza, altezza. Basta per trovare l'ultimo lotto, il
  `y` dell'ultima riga e i frame del lotto.

## Configurazione

`controlla.sh configura` aggiunge una riga **Token Figma**, con `figma.sh verifica`:
- ✅ con il nome dell'account;
- ❌ con il passo da fare: creare il token su figma.com (Impostazioni, Sicurezza, Personal access token, 90 giorni,
  i quattro scope), copiarlo e **poi** lanciare `security add-generic-password -U -s figma-token -a "$USER" -w "$(pbpaste)"`.

La riga non è bloccante: senza token il giro funziona come oggi, solo con più chiamate MCP.

## Nel giro (modifiche a SKILL.md)

- **Passo 2, brand kit:** struttura e schermate delle linee guida con `figma.sh` (tutte le sezioni in una chiamata).
  Foto e schermate del prodotto per le reference della scena con `figma.sh immagini`, invece di esportarle a mano.
- **Passo 6, Figma:** l'ultimo lotto e la posizione delle righe con `figma.sh struttura`. Montaggio con `use_figma` e
  `upload_assets` come oggi. Il controllo finale dei frame con **una** chiamata `figma.sh schermate` per tutti i frame
  del giro.
- `create_session` resta prima di ogni scrittura MCP.

## Il giro delle correzioni (nuovo)

**Quando parte:** la persona chiede di sistemare i commenti di un lotto («sistema i commenti del B10», un link a una
pagina con «correggi»). Non parte da solo durante un giro di creazione.

1. `figma.sh commenti <file> <pagina>`: commenti **aperti** (`resolved_at` vuoto), di primo livello, su frame di quella
   pagina. Il frame si trova da `client_meta.node_id` (risalendo al frame del lotto) o, per i commenti appoggiati sulla
   tela, dalla posizione x, y dentro i riquadri dei frame. Si saltano quelli in cui l'ultimo messaggio è **una risposta di
   chi lancia il giro** (`/v1/me`) che comincia con «Fatto:» o «Non fatto:»: sono già stati sistemati e aspettano che
   qualcuno li risolva.
2. Per ogni frame, le correzioni raggruppate:
   - **testi, colori, posizioni, logo:** con `use_figma` sul frame commentato. Le correzioni di **contenuto** (un
     testo, un colore, il logo) vanno anche sull'altro formato della stessa variante; quelle di **posizione o misura**
     solo sul frame commentato. Mai sulle altre varianti (`C1` non tocca `C1-2`). Nel dubbio solo il frame
     commentato, e la risposta al commento lo dice;
   - **scena da cambiare:** nuova scena su Higgsfield con il prompt corretto, costo detto prima («uso N crediti»), poi
     `upload_assets` nel rettangolo `Scena` dei due formati.
3. Una sola chiamata `figma.sh schermate` per tutti i frame toccati, controllo con occhio critico.
4. Su ogni commento: risposta «Fatto: <cosa è cambiato>» e reazione ✅. Se una correzione non si può fare o va contro le
   regole del cliente, risposta «Non fatto: <motivo>», senza ✅.
5. Resoconto: frame toccati con link, commenti sistemati, commenti lasciati con il motivo, crediti usati.

Le regole del giro valgono anche qui: nessuna domanda se i commenti sono chiari; una domanda sola se un commento è
ambiguo, e intanto si sistemano gli altri.

## Le pagine del file del cliente (Max, 03/11)

Ogni file cliente ha tre tipi di pagina:
- **«Brand kit»**, come oggi;
- **«Foto e immagini»**, la raccolta delle scene generate;
- **una pagina per brief**, `B<n>_ <data>`, solo con le creatività finite.

- **Alla fine di ogni brief** le scene generate vanno anche in «Foto e immagini». Se la pagina manca, si crea. Si usa lo
  stesso `imageHash` già caricato nei frame, quindi niente nuovo caricamento. Un rettangolo per scena, con il nome
  dell'ad (`B<n>_ <data> - C<k>`, `C<k>-2`...) e la misura dell'immagine. Una riga per brief, la più recente in alto,
  con sopra il nome del lotto come testo.
- **Il brand kit si arricchisce piano piano.** Un giro può aver bisogno di un elemento grafico del cliente che nel
  brand kit non c'è: bollini, icone, pattern, schermate del prodotto. Se lo trova sul sito del cliente, Claude lo
  estrae e lo mette nel brand kit, in un riquadro **«Da verificare»**, con la fonte (l'indirizzo della pagina). Il
  team lo guarda e lo sposta nella sezione giusta. Finché resta lì non entra nei giri successivi. Nel resoconto si
  scrive cosa è stato aggiunto.

## Ad senza copy (Max, 03/11)

Vale per la statica da riadattare **e** per le ad di un brief che non hanno testi (un brief con reference e senza
copy, o con il copy solo per alcune ad).

- I due subagenti girano **sempre**, in parallelo, anche per una sola ad: `format-concept` su format e concept,
  `visual-testi` su visual e copy. Con un brief, la statica che ricevono è la reference del brief e le note del brief
  vanno insieme al materiale.
- Claude passa ai subagenti il **testo intero** delle istruzioni e delle skill del cliente per creatività e copy, letto
  dalla wiki, non un riassunto: i subagenti hanno solo Read e la wiki non la leggono da soli.
- `visual-testi`, per ogni testo (headline, testi brevi, CTA): quale regola o skill del cliente ha seguito. Se il
  cliente non ha regole sui copy, lo dice.
- Prima di Figma Claude controlla i copy contro le regole del cliente (lunghezze, parole vietate, tono, promesse) e
  corregge quello che non torna. Nel resoconto: i copy, con le regole applicate in una riga.
- Le ad del brief **con** copy restano come oggi: testi usati così come sono, niente subagenti.
- **Brief con copy a metà** (c'è la headline, manca la CTA): i testi del brief restano così come sono, i subagenti
  scrivono solo i pezzi che mancano, coerenti con quelli presenti.
- **Brief senza copy:** concept e note del brief (impianto, scena, persona) sono vincolanti. `format-concept` legge il
  visual della reference e propone le esecuzioni delle varianti dentro quel concept, senza idee nuove.
- I copy sono **uno per variante**: ogni variante (`C<k>`, `C<k>-2`, `C<k>-3`) ha i suoi, uguali fra 9:16 e 1:1.
- Quali file passare: quelli che `elenca_knowledge` e `cerca_nella_knowledge` trovano in `clienti/<slug>` su creatività,
  copy, tono e visual (per Learnn anche la knowledge portata da GitHub). Le parti su copy e visual si passano intere;
  se un file è molto lungo, si tagliano le parti che non riguardano le ad statiche, e nel resoconto si scrive cosa si
  è passato.

## Scelte mie, da controllare

- «Il loro dovere del controllo, il visual» l'ho letto come: i due subagenti analizzano sempre il visual della
  reference e i copy, nessuno dei due si salta. Non ho previsto che rivedano anche le scene generate: il controllo
  critico delle scene resta a Claude (passo 5).
- Script in bash con curl, come `controlla.sh`, invece di un server MCP nuovo: niente da installare per il team.
- La reazione ✅ e la risposta «Fatto» al posto della risoluzione, che l'API non permette.
- Il giro delle correzioni parte solo su richiesta, non a ogni giro di creazione.
- Composio non entra nel plugin.
- In «Foto e immagini»: una riga per brief, la più recente in alto. Gli elementi estratti dal sito vanno in un
  riquadro «Da verificare» e non si usano finché il team non li sposta.
- Brief con copy a metà: si scrivono solo i pezzi mancanti. Brief senza copy: il concept del brief è vincolante.
- Copy uno per variante.
- Correzioni: contenuto sui due formati, posizione solo sul frame commentato, mai sulle altre varianti.

## Verificato il 03/11 (Sezione 1 del piano)

- **Portachiavi in auto mode:** la lettura della voce `figma-token` passa. La ricerca generica dei token era stata
  bloccata, quella di una voce precisa no. Non serve nessuna regola di permesso.
- **Lettura dopo scrittura:** nessun ritardo. Un testo cambiato con `use_figma` si legge già cambiato con l'API
  dopo 1 secondo, sia nei nodi che nel render. Il render di un frame impiega circa 6 secondi.
- **Commenti:** `POST` con `client_meta` `{node_id, node_offset}` crea il commento sul frame. La risposta con
  `comment_id` funziona. La reazione `{"emoji":":white_check_mark:"}` torna 200 e si rilegge. Commenti, risposte e
  reazioni compaiono **a nome di chi ha il token**.
- **Filtro dei thread già sistemati, corretto:** se il commento lo scrive la stessa persona che lancia il giro, la regola
  «ultimo messaggio di chi lancia il giro» lo scarterebbe subito. Si scartano solo i thread il cui ultimo messaggio è
  una **risposta** di chi lancia il giro che comincia con «Fatto:» o «Non fatto:». Per questo le risposte del giro
  cominciano sempre così.

## Lasciato a chi costruisce

- Il formato preciso delle stampe di `figma.sh` (tabella o JSON compatto) e come si risale da un nodo figlio al frame
  del lotto.
- I test dello script con risposte finte dell'API (come `controlla.test.sh`).
- Dove scrivere nella skill il passaggio da API a MCP, purché sia una regola sola e non ripetuta in ogni passo.

## Coordinamento

Lo costruisce la sessione che sta lavorando sul plugin, oppure un'altra, ma una alla volta: oggi su `SKILL.md`,
`agents/format-concept.md` e il design generale ci sono modifiche non ancora committate. Si parte solo dopo il loro
commit, e su quella base. File toccati: `SKILL.md`,
`agents/visual-testi.md`, `agents/format-concept.md`, `scripts/figma.sh` (nuovo, più il suo test),
`scripts/controlla.sh`, il design generale (vincoli: limiti MCP e API).
