---
name: creativita
description: Crea ad statiche per un cliente LTV/Beat, nel suo brand kit su Figma, con le scene generate su Higgsfield e montate su Figma. Usala quando la persona passa una statica da riadattare per un cliente, o un brief già pronto con testi e reference da realizzare, e quando la creazione creatività è accesa (/creativita on) e arriva una statica o un brief. Anche per sistemare i commenti lasciati dal team sui frame di un lotto («sistema i commenti del B10»).
---

# Creazione creatività: il giro

Si producono **ad** statiche nel brand del cliente: scena su Higgsfield, montaggio su Figma. Due ingressi:

- **Statica da riadattare:** il ragionamento è quello di Giotto. Per ogni statica **format** (cos'è graficamente),
  **significato** (cosa vuole dire), **adattamento** al materiale vero del cliente. Né identica né così diversa da
  perdere il concept.
- **Brief pronto:** testi e reference già decisi (vedi «Ingresso dal brief»). Non si reinventa niente: si realizza il
  brief nel brand del cliente.

**Il giro è il più veloce possibile** (Max, 03/11). Si fa **una sola domanda**, quante varianti per ad, poi si va fino
a Figma senza fermarsi: niente conferma del brand, delle proposte, dei prompt, del costo o delle scene. La persona
sceglie dentro Figma.

## La fase nella fascia

Se nelle istruzioni del messaggio c'è «CREAZIONE CREATIVITÀ ATTIVA», lì trovi il file della sessione e il comando per
scriverci la fase. Scrivila a ogni passaggio: `analisi` (passi 1-3), `proposte` (passo 4), `scena` (passo 5),
`figma` (passo 6). Se la creazione è spenta, salta questi comandi e alla fine ricorda che `/creativita on` mostra la
fascia.

## Letture e scritture su Figma

L'MCP di Figma ha un tetto (200 chiamate al giorno con un posto Full); l'API REST no. Quindi:

- **Le letture si fanno con lo script** `bash "${CLAUDE_PLUGIN_ROOT}/scripts/figma.sh"`:

  | Serve | Comando | Al posto di |
  |---|---|---|
  | pagine, frame, posizioni | `struttura <file> [nodo] [profondità]` | `get_metadata` |
  | vedere sezioni o frame | `schermate <file> <nodo>... [--scala N]`, **tutti i nodi in una chiamata** | `get_screenshot` |
  | foto e schermate originali | `immagini <file> <nodo>` | esportarle a mano |
  | commenti da sistemare | `commenti <file> <pagina>`, `rispondi`, `reazione` | (l'MCP non li legge) |

  `struttura` stampa `id tipo nome x y larghezza altezza genitore`; `schermate` e `immagini` scaricano in una cartella
  temporanea e stampano i percorsi, che poi leggi con Read.
- **Le scritture restano all'MCP:** `create_session` prima, poi `use_figma` e `upload_assets`. L'API vede subito quello
  che l'MCP ha scritto.
- Se lo script esce con **3** (token mancante o scaduto) o **4** (limite dell'API), quella lettura la fai con l'MCP e lo
  scrivi nel resoconto, con il messaggio dello script (dice come rifare il token).

## Il giro

### 1. Statica, cliente, materiale e varianti

- La statica è l'immagine che la persona ha incollato: il suo file è nella riga `[Image: source: <percorso>]` del
  messaggio. Se non c'è un'immagine, chiedila.
- Il cliente: se non lo dice, chiedilo. Lo slug è la cartella in `clienti/` della wiki (`elenca_knowledge` con
  `clienti`).
- Il materiale vero (il corso, il prodotto, il servizio): se non lo dice, scegli quello più adatto dalla wiki e
  scrivilo nel resoconto finale.
- **L'unica domanda:** con il riquadro delle domande (AskUserQuestion), quante varianti per ogni ad: 1, 2 o 3.

### 2. Il brand: Figma e wiki

Si dà per scontato che brand kit su Figma e wiki del cliente siano corretti: si leggono **sempre**, si usano e non si
chiede conferma.

- **Brand kit su Figma.** Il link del file: cerca `figma.com/design` nella cartella `clienti/<slug>` della wiki. Se non
  c'è, chiedi il link del file del cliente nella sua cartella del team Beat Performance, e a fine giro suggerisci di
  scriverlo nella scheda del cliente. Le pagine del file con `figma.sh struttura <file> "" 1`, quella del brand kit con
  `figma.sh struttura <file> <pagina> 1`. Il brand kit è la pagina **«Brand kit»**: «Asset · 01 Logo», «02 Esperti»,
  «03 Immagini», «04 Terze parti» e «Linee guida». Le linee guida si guardano sezione per sezione, tutte con **una**
  `figma.sh schermate` sui nodi delle sezioni. Ne ricavi palette con codici e ruoli, divieti, font, varianti del logo,
  foto ed elementi disponibili. Le foto e le schermate del prodotto da usare come reference della scena si scaricano
  con `figma.sh immagini <file> <nodo>` (per esempio sul nodo «Asset · 03 Immagini»).
- **Il brand kit cresce piano piano** (Max, 03/11). Se al giro serve un elemento grafico del cliente che nel brand kit
  non c'è (un bollino, un'icona, un pattern, una schermata del prodotto) e lo trovi sul sito del cliente, estrailo e
  mettilo nella pagina «Brand kit», in un riquadro **«Da verificare»** (crealo se manca), con l'indirizzo della pagina
  da cui viene. Quello che sta in «Da verificare» **non si usa** nei giri: il team lo guarda e lo sposta nella sezione
  giusta. Nel resoconto scrivi cosa hai aggiunto.
- **Wiki, sezione creatività del cliente.** Nella cartella del cliente ci sono le istruzioni e le **skill del
  cliente** per le creatività (per Learnn, per esempio, i file sulle creatività e la knowledge portata da GitHub):
  trovale con `elenca_knowledge` e `cerca_nella_knowledge`, leggile e **seguile nei momenti in cui servono**: regole dei
  testi quando scrivi i copy, regole visive quando scrivi i prompt, regole di formato quando monti su Figma.
- Il brand kit su Figma vince sul visual, la wiki su tono e testi. Se si contraddicono, scegli la regola più recente e
  scrivilo nel resoconto.
- Nel resoconto finale scrivi in due righe il brand usato: colori con codici, font, elementi.
- Se il cliente non ha un brand kit su Figma, dillo e fermati: si prepara prima.

### 3. Due analisi in parallelo (ogni ad senza copy)

Vale per la statica da riadattare **e** per le ad del brief senza testi (Max, 03/11): i due subagenti girano
**sempre**, anche per una sola ad, e nessuno dei due si salta. Lancia insieme, nello stesso messaggio,
**`creativita:format-concept`** e **`creativita:visual-testi`**. A tutti e due di' che si sta creando un'ad statica per
Meta (9:16 e 1:1) e passa: il percorso della statica (con un brief, la sua reference, più le note del brief), il
cliente, il riassunto del brand kit (palette con ruoli e divieti, font, logo, elementi e foto), il materiale vero e il
numero di varianti.

Le istruzioni e le skill del cliente su creatività, copy, tono e visual (quelle trovate al passo 2) si passano **con il
testo intero**, non riassunte: i subagenti hanno solo Read e la wiki non la leggono da soli. Se un file è molto lungo,
taglia solo le parti che non riguardano le ad statiche, e nel resoconto scrivi cosa hai passato.

### 4. Le varianti

Unisci le analisi in tante varianti quante richieste, senza chiedere conferma. Per ognuna:
- **Idea:** format e significato riadattati al materiale vero, e perché non è una copia.
- **Scena:** il prompt per l'immagine, in inglese. **Comincia sempre dicendo che è un'ad**: «Paid social static ad
  image (Meta, 9:16) for <cliente>, <cosa vende>». Dentro: «recreate the format of the reference», soggetto e
  composizione, i colori del brand kit con codici e ruolo, lo stile, gli spazi vuoti per i testi che vanno su Figma, e
  «no other text»: senza, il modello aggiunge poster e cartelli con scritte inventate.
- **Si genera l'immagine intera, in un colpo** (Max, 03/11): dispositivi con lo schermo acceso, post-it, regali,
  bollini, grafica. Niente elementi generati a parte e niente schermi bianchi da riempire.
  - **Schermi:** il contenuto si genera, con la schermata vera del brand kit come seconda `--image-references`
    (sito, app): così lo schermo somiglia al prodotto vero.
  - **Testi dentro l'immagine** quando su Figma verrebbero brutti: scritti a mano (post-it, Paint, pennarello),
    inclinati, in prospettiva, su un oggetto; anche la grafica con lettere o numeri, come un «-40€» in 3D. Nel prompt
    il testo esatto tra virgolette e «spell it exactly», poi si controlla lettera per lettera.
  - **Su Figma solo la tipografia pulita:** headline, sottotitoli, testi brevi, CTA, disclaimer, logo.
- **Il format non si cambia.** Il protagonista della reference resta: se è un pupazzo resta un pupazzo, non diventa
  una persona. Se è un personaggio famoso protetto, se ne fa uno **originale dello stesso tipo** e lo si dice nel
  resoconto.
- **Materiale vero del cliente al posto degli oggetti generici:** se la reference ha un prodotto o un regalo, al suo
  posto va qualcosa del cliente (per Learnn, un telefono con un corso), non un oggetto qualsiasi.
- **Copy:** headline, testi brevi e CTA, nel tono e con le regole del cliente, con il font del brand kit. Uno per
  variante, uguali fra 9:16 e 1:1. Prima di Figma **controlla ogni testo contro le regole e le skill del cliente**
  (lunghezze, parole vietate, tono, promesse che il materiale vero non sostiene) e correggi quello che non torna; nel
  resoconto ogni copy ha accanto, in una riga, le regole applicate.
- **Dal brand kit:** loghi da mettere su Figma; schermate e foto da usare come reference della scena. Testimonianze e
  numeri di prova non si inventano.

### 5. Le scene su Higgsfield

- Modello (Max, 03/11): **GPT Image 2.5 Sunburst**, `gpt_image_2_5 --variant sunburst --quality xhigh --resolution 1k
  --aspect_ratio 9:16`. La statica o la reference del brief va come prima `--image-references`.
- **Il costo si dice, non si chiede:** `higgsfield generate cost`, poi una riga «uso N crediti» e si parte. Nessun
  tetto di crediti (Max, 03/11).
- `higgsfield generate create ... --wait`; scarica l'immagine in una cartella temporanea. Più scene si possono lanciare
  insieme, **al massimo 4** (il piano pro rifiuta la quinta con `rate_limit_reached`, senza spendere: si rilancia).
- Un'ad fatta solo di testo su fondo pieno (un messaggio, un titolo su nero) **non si genera**: si fa tutta su Figma.
- **Controlla ogni scena con occhio critico:** numeri e lettere della grafica (un «4» che sembra un «7», una «€»
  deformata), colori rispetto al brand, mani e volti, oggetti non richiesti. Se c'è un difetto chiaro, **una**
  rigenerazione automatica con il prompt corretto; se resta, la scena va su Figma lo stesso e il
  difetto si scrive nel resoconto.
- Una scena che finisce con stato `nsfw` è quasi sempre un falso positivo, spesso per una reference con un personaggio
  famoso: i crediti tornano (`higgsfield account transactions`). Si rilancia una volta senza quella reference,
  descrivendo il format a parole.
- Per mettere un testo su Figma dentro una zona della scena (la pagina di un documento, un cielo libero), misura la
  zona nell'immagine con uno script (righe e colonne di pixel chiari) invece di stimarla a occhio.
- Se la CLI risponde «No workspace selected», fermati e chiedi di scegliere il workspace con
  `higgsfield workspace list` e `higgsfield workspace set <id>`.

### 6. Su Figma

Prima di scrivere su Figma carica le istruzioni obbligatorie dell'MCP di Figma (`figma-use` e
`figma-generate-design`, anche come risorse `skill://figma/...`). Poi, nel file del cliente.

Il file del cliente ha tre tipi di pagina (Max, 03/11): **«Brand kit»**, **«Foto e immagini»** (la raccolta delle scene
generate) e **una pagina per brief**, `B<n>_ <data>`.

1. **Pagina del lotto** `B<n>_ <data>` (dal brief, o il lotto successivo all'ultimo): se non c'è, creala. Se la
   persona dà un link a una pagina, le ad vanno lì. Pagine, frame e posizioni con `figma.sh struttura`: se la pagina
   ha già delle ad, le nuove vanno nelle righe libere sotto l'ultima, senza toccare quelle esistenti.
2. **Nella pagina solo creatività finite e modificabili** (Max, 03/11): niente riquadro degli asset, niente prove,
   niente frame di servizio. La scena si carica direttamente nel rettangolo `Scena` del frame: crea prima il frame con
   il rettangolo vuoto, poi `upload_assets` puntando a quel rettangolo (`nodeIds`) e invia con curl in multipart; la
   risposta dà l'`imageHash`, che si riusa per il rettangolo `Scena` dell'altro formato.
3. **Due frame per ogni variante**, 1080×1920 e 1080×1080: `B<n>_ <data> - C<k> - 9:16` e `- 1:1` per la prima,
   `C<k>-2`, `C<k>-3` per le altre (la convenzione già usata nei lotti). Fondo nero, contenuto tagliato. Dentro:
   - `Scena`: rettangolo largo 1080 con l'immagine (`imageHash`, FILL). Nel 1:1 spostalo in verticale perché restino
     in quadro soggetto e grafica.
   - I testi come livelli, nel font del brand kit (se manca in Figma, il sostituto indicato dal brand kit) e nei suoi
     colori, nello spazio lasciato libero dalla scena.
   - Il logo come **istanza del componente del brand kit** (per Learnn «Logo Learnn / Bianco»), non come testo.
   - Le istanze (logo, schermate dell'app) si scalano con `rescale()`, non con `resize()`: `resize` cambia il riquadro
     ma non il contenuto, e la schermata esce tagliata.
   - Un blocco di testi in auto layout va lasciato crescere (`primaryAxisSizingMode = "AUTO"`): dopo un `resize`
     resta fisso e taglia il contenuto, e i testi spariscono senza errori.
   - Le ad con più ad nello stesso lotto vanno in righe come nei lotti già fatti: 9:16 a x 4200 e 1:1 a x 5400,
     una riga ogni 2100 px per concept (C1 a y 0, C2 a y 2100...). In una pagina che ha già delle ad, la prima riga
     nuova va 2100 px sotto l'ultima.
   - **Safe zone del cliente**, se la wiki la indica (per Learnn, 9:16: area utile x 65-1015, y 269-1248): testi, logo,
     CTA e soggetti essenziali dentro; lo sfondo può andare al vivo.
4. Guarda i frame con **una** `figma.sh schermate` su tutti i frame del giro: testi tagliati, sovrapposti alla grafica o
   fuori dalla zona sicura si correggono subito.
5. **Le scene in «Foto e immagini»**, a brief finito: se la pagina non c'è, creala. Una riga per brief, la più recente
   in alto, con sopra il nome del lotto come testo; un rettangolo per scena, con la misura dell'immagine e il nome
   dell'ad (`B<n>_ <data> - C<k>`, `C<k>-2`...), riempito con lo **stesso `imageHash`** già caricato nei frame: niente
   nuovo caricamento.

### 7. Il resoconto

Uno solo, alla fine: link alla pagina e ai frame su Figma, schermate, crediti usati, brand usato in due righe, copy con
le regole applicate, difetti rimasti, elementi aggiunti al brand kit in «Da verificare», letture fatte con l'MCP
invece che con lo script, e scelte fatte da te (materiale, regole in conflitto). La persona sceglie le varianti dentro
Figma.

## Ingresso dal brief

La persona passa un brief già pronto: testi (headline, testi, CTA) e una o più reference, a volte già divise in più ad.

1. Leggi il brief: quali ad, per ognuna testi e reference. Se manca il cliente, chiedilo insieme alle varianti.
   - I brief del team sono Google Doc con una scheda per lotto (`B<n>_ <data>`) e le concept numerate. Il testo si
     legge con il connettore di Google Drive. Le reference sono immagini dentro il Doc e la lettura del testo non le
     porta: si prendono con Composio, `GOOGLEDOCS_GET_DOCUMENT_BY_ID` con `includeTabsContent` e l'account
     massimo.cardini@ltvalue.it. Nella scheda giusta, l'immagine che segue «Concept Static Image #<n>» è un
     `inlineObjectElement`, e il suo `imageProperties.contentUri` si scarica con curl. L'indirizzo scade in pochi
     minuti: se curl fallisce, rileggi il Doc per averne uno nuovo.
   - Il lotto del brief è anche il nome della pagina Figma in cui vanno le ad (`B<n>_ <data>`).
2. L'unica domanda: quante varianti per ogni ad (1, 2 o 3).
3. Brand come al passo 2.
4. Niente idee nuove: concept e note del brief (impianto, scena, persona) sono vincolanti ed entrano nel prompt.
   - **Ad con i testi:** niente subagenti. I testi del brief **si usano così come sono**. Se un testo va contro le
     regole del cliente o non entra nel formato, usalo comunque e segnalalo nel resoconto con la correzione proposta.
   - **Ad con i testi a metà** (c'è la headline, manca la CTA): i testi del brief restano come sono; i pezzi mancanti
     li scrivono i subagenti del passo 3, coerenti con quelli presenti.
   - **Ad senza testi:** passo 3 completo. Le varianti sono esecuzioni dentro il concept del brief, e i copy si
     scrivono con le regole e le skill del cliente.
5. Da qui come i passi 4, 5, 6 e 7 (per le ad con i testi, del passo 4 solo la scena).

## Il giro delle correzioni

Parte quando la persona chiede di sistemare i commenti di un lotto («sistema i commenti del B10», un link a una pagina
con «correggi»). Non parte da solo durante un giro di creazione. Nessuna domanda se i commenti sono chiari; se uno è
ambiguo, una domanda sola su quello, e intanto sistemi gli altri.

1. `figma.sh commenti <file> <pagina>`: una riga per commento da sistemare, con frame, autore, data e il thread intero
   (`radice // risposta // ...`). Lo script salta i risolti, quelli di altre pagine e i thread già chiusi da una
   risposta tua che comincia con «Fatto:» o «Non fatto:». Le righe `NON ATTRIBUITO` non sono legate a un frame: leggile
   e, se dicono di quale ad parlano, trattale come le altre.
2. Per ogni frame, le correzioni raggruppate:
   - **testi, colori, posizioni, logo:** con `use_figma` sul frame commentato. Le correzioni di **contenuto** (un testo,
     un colore, il logo) vanno anche sull'altro formato della stessa variante; quelle di **posizione o misura** solo sul
     frame commentato. Mai sulle altre varianti (`C1` non tocca `C1-2`). Nel dubbio solo il frame commentato, e la
     risposta lo dice.
   - **scena da cambiare:** nuova scena su Higgsfield con il prompt corretto, costo detto prima («uso N crediti»), poi
     `upload_assets` nel rettangolo `Scena` dei due formati, e la nuova scena anche in «Foto e immagini».
   - Le regole del cliente valgono anche qui: una correzione che le viola non si fa.
3. Una sola `figma.sh schermate` su tutti i frame toccati, e controllo con occhio critico.
4. Su ogni commento: `figma.sh rispondi <file> <commento> "Fatto: <cosa è cambiato>"` e `figma.sh reazione <file>
   <commento>` (✅). Se non si può fare: `"Non fatto: <motivo>"`, senza ✅. Le risposte cominciano **sempre** con
   «Fatto:» o «Non fatto:»: è così che il giro dopo le salta. I commenti non si risolvono (l'API non lo permette): li
   risolve il team su Figma.
5. Resoconto: frame toccati con link, commenti sistemati, commenti lasciati con il motivo, crediti usati.

## Regole

- Si creano sempre **ad**: ogni prompt di scena lo dice esplicitamente, e anche le richieste ai subagenti.
- Nessuna regola di un cliente sta in questa skill: si leggono a ogni giro da Figma e dalla wiki.
- Prove (testimonianze, numeri, screenshot, volti di clienti o studenti) solo da materiale vero, mai generate.
- Il token di Higgsfield non si chiede mai alla CLI. Il token di Figma lo legge solo `figma.sh`, dal Portachiavi: non
  si stampa e non si cerca in altri modi.
- Scrivi in italiano, asciutto.
