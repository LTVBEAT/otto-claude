---
name: creativita
description: Crea ad statiche per un cliente LTV/Beat, nel suo brand kit su Figma, con le scene generate su Higgsfield e montate su Figma. Usala quando la persona passa una statica da riadattare per un cliente, o un brief già pronto con testi e reference da realizzare, e quando la creazione creatività è accesa (/creativita on) e arriva una statica o un brief. Anche quando la persona chiede di correggere un'ad già fatta («nella C2 il titolo più grande»), quando dà un feedback sulle creatività fatte, e quando chiede quali indicazioni o feedback hai sulle creatività.
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

**Eccezione, i testi scelti dalla persona** (Max, 03/11, B15): se chiede di scegliere lei i testi («proponimi i
testi», «i testi li decido io»), al passo 4 le proponi due o tre testi per ogni ad che ne ha bisogno, con il riquadro
delle domande, e **intanto generi le scene che non dipendono dalla scelta**: quelle senza testo nella scena, e quelle
delle ad con il testo già deciso. Le scene con il testo dentro (un biglietto, un post-it, il vapore) partono dopo la
risposta. I testi su Figma non bloccano niente: si montano quando arriva la scelta.

## Il feedback

I feedback sono le indicazioni date guardando le creatività che valgono **sempre**, per i giri futuri. Stanno in due
posti, e li dà tutti e due `bash ${CLAUDE_PLUGIN_ROOT}/scripts/feedback.sh mostra`:

- **Feedback del team:** il `feedback.md` del plugin, scelto da Max e uguale per tutti. Lo cambia solo Max, a mano:
  **tu non ci scrivi mai**, nemmeno se te lo chiedono (di' che i feedback per tutti li sceglie Max).
- **I feedback della persona:** il suo file, sul suo computer, che resta quando il plugin si aggiorna.

Come si usano:

- **Si leggono a ogni giro**, al passo 2, con `feedback.sh mostra`, e si seguono: nei prompt, nei copy, nel
  montaggio. Vincono su brand kit, wiki e reference quando li contraddicono. Se quelli della persona contraddicono
  quelli del team, per lei vincono i suoi. Nel resoconto scrivi dove hanno deciso loro.
- **Si passano interi ai subagenti** del passo 3 (tutta l'uscita di `mostra`), insieme alle regole del cliente.
- **Quando la persona dà un'indicazione** sulle creatività (anche dentro un messaggio su altro): se è chiaro che vale
  solo per l'ad o il lotto di adesso è una correzione, e si sistema e basta. Se è chiaro che vale sempre, salvala.
  Se non è chiaro, chiedi in una riga: «Vale solo qui o sempre?».
- **Per salvarla:** `feedback.sh aggiungi tutti "<testo> (<nome>, <gg/mm>)"` se vale per ogni cliente, oppure
  `feedback.sh aggiungi <Cliente> "<testo> (<nome>, <gg/mm>)"` se vale per un cliente solo. Una riga per
  indicazione, scritta chiara come una regola. Poi di' in una riga cosa hai salvato. Se contraddice una riga vecchia
  della persona, togli la vecchia con Edit nel file che dà `feedback.sh percorso`.
- **Quando la persona chiede quali indicazioni hai**, mostrale l'uscita di `feedback.sh mostra`: prima quelle del
  team, poi le sue.

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
  | foto e schermate originali | `immagini <file> <nodo>`, anche sul nome dell'asset: risale da solo al riquadro dell'immagine | esportarle a mano |

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
chiede conferma. Insieme si leggono i feedback con `feedback.sh mostra` (vedi «Il feedback»), che vincono su tutti e due.

- **Prima la scheda del cliente** (Max, 05/11): `leggi_dalla_knowledge` su `clienti/<slug>/creativita.md`. È il punto
  d'ingresso fisso: dice dove sono il file Figma, i materiali, le linee guida, le regole del copy, le skill del cliente
  e gli **elementi fissi dell'ad** (CTA, prove, logo, card di ripiego, safe zone), che userai ai passi 4 e 6.
- **Se il cliente non è pronto, il giro si ferma.** Manca la scheda, nella scheda manca il link Figma, oppure nel file
  non c'è la pagina «Brand kit»: di' «<Cliente> non è ancora pronto per il plugin: manca <cosa>. Il modello della
  scheda è in `${CLAUDE_PLUGIN_ROOT}/scheda-modello.md`» e non andare avanti. Non chiedere il link in chat.
- **Brand kit su Figma.** Il file è quello della scheda. Le pagine del file con `figma.sh struttura <file> "" 1`, quella
  del brand kit con `figma.sh struttura <file> <pagina> 1`. Il brand kit è la pagina **«Brand kit»**, di solito con
  «Asset · 01 Logo», «02 Esperti», «03 Immagini», «04 Terze parti» e «Linee guida». Le linee guida si guardano sezione per sezione, tutte con **una**
  `figma.sh schermate` sui nodi delle sezioni. Ne ricavi palette con codici e ruoli, divieti, font, varianti del logo,
  foto ed elementi disponibili. Le foto e le schermate del prodotto da usare come reference della scena si scaricano
  con `figma.sh immagini <file> <nodo>` (per esempio sul nodo «Asset · 03 Immagini»).
- **Il brand kit cresce piano piano** (Max, 03/11). Se al giro serve un elemento grafico del cliente che nel brand kit
  non c'è (un bollino, un'icona, un pattern, una schermata del prodotto) e lo trovi sul sito del cliente, estrailo e
  mettilo nella pagina «Brand kit», in un riquadro **«Da verificare»** (crealo se manca), con l'indirizzo della pagina
  da cui viene. Quello che sta in «Da verificare» **non si usa** nei giri: il team lo guarda e lo sposta nella sezione
  giusta. Nel resoconto scrivi cosa hai aggiunto.
- **Wiki, istruzioni e skill del cliente.** Sono i file che la scheda elenca (se serve, cercane altri con
  `elenca_knowledge` e `cerca_nella_knowledge` nella cartella del cliente): leggili e **seguili nei momenti in cui
  servono**: regole dei
  testi quando scrivi i copy, regole visive quando scrivi i prompt, regole di formato quando monti su Figma.
- Il brand kit su Figma vince sul visual, la wiki su tono e testi. Se si contraddicono, scegli la regola più recente e
  scrivilo nel resoconto.
- Nel resoconto finale scrivi in due righe il brand usato: colori con codici, font, elementi.

### 3. Due analisi in parallelo (ogni ad senza copy)

Vale per la statica da riadattare **e** per le ad del brief senza testi (Max, 03/11): i due subagenti girano
**sempre**, anche per una sola ad, e nessuno dei due si salta. Lancia insieme, nello stesso messaggio,
**`creativita:format-concept`** e **`creativita:visual-testi`**. A tutti e due di' che si sta creando un'ad statica per
Meta (9:16 e 1:1) e passa: il percorso della statica (con un brief, la sua reference, più le note del brief), il
cliente, il riassunto del brand kit (palette con ruoli e divieti, font, logo, elementi e foto), il materiale vero e il
numero di varianti.

Le istruzioni e le skill del cliente su creatività, copy, tono e visual (quelle trovate al passo 2) e i feedback (l'uscita di `feedback.sh mostra`) si
passano **con il testo intero**, non riassunte: i subagenti hanno solo Read e la wiki non la leggono da soli. Se un file è molto lungo,
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
  - **Il testo piatto sopra la foto va su Figma, mai nella scena** (Max, 03/11, B15): citazioni, didascalie da meme,
    titoli e frasi in sovrimpressione, anche se nella reference sembrano parte dell'immagine. Nel prompt si lascia la
    zona vuota e si scrive «no text». Si genera solo il testo che sta **su un oggetto** della scena. Nel dubbio, va su
    Figma: un testo generato per errore costa una scena rifatta.
- **Il format non si cambia.** Il protagonista della reference resta: se è un pupazzo resta un pupazzo, non diventa
  una persona. Se è un personaggio famoso protetto, se ne fa uno **originale dello stesso tipo** e lo si dice nel
  resoconto.
- **Materiale vero del cliente al posto degli oggetti generici:** se la reference ha un prodotto o un regalo, al suo
  posto va qualcosa del cliente (un telefono con il suo prodotto, un suo corso), non un oggetto qualsiasi.
- **Copy:** headline, testi brevi e CTA, nel tono e con le regole del cliente, con il font del brand kit. Uno per
  variante, uguali fra 9:16 e 1:1. Prima di Figma **controlla ogni testo contro le regole e le skill del cliente**
  (lunghezze, parole vietate, tono, promesse che il materiale vero non sostiene) e correggi quello che non torna; nel
  resoconto ogni copy ha accanto, in una riga, le regole applicate.
- **Dal brand kit:** loghi da mettere su Figma; schermate e foto da usare come reference della scena. Testimonianze e
  numeri di prova non si inventano.

### 5. Le scene su Higgsfield

- Modello (Max, 03/11): **GPT Image 2.5 Sunburst**, `gpt_image_2_5 --variant sunburst --quality xhigh --resolution 1k
  --aspect_ratio 9:16`. La statica o la reference del brief va come prima `--image-references`.
- **Le scene si lanciano con lo script** `bash "${CLAUDE_PLUGIN_ROOT}/scripts/scene.sh"`, non con comandi scritti a
  mano. In una cartella temporanea del giro, per ogni scena `<nome>.txt` con il prompt e, se servono, `<nome>.ref` con
  le reference, un percorso per riga, prima la statica o la reference del brief. Nome della scena = nome dell'ad
  (`c1`, `c1-2`...).
  - `scene.sh costo <cartella>`: i crediti di tutte le scene. **Il costo si dice, non si chiede:** una riga «uso N
    crediti» e si parte. Nessun tetto di crediti (Max, 03/11).
  - `scene.sh genera <cartella> [nome...]`: lancia quelle senza PNG (o solo quelle nominate, per rifarle), al massimo 4
    insieme, rilancia da solo i rifiuti per `rate_limit_reached` (non spendono), scarica in `<nome>.png` e stampa una
    riga `nome<TAB>percorso`, oppure `NSFW` o `ERRORE <motivo>`. Mettilo in background se le scene sono più di due.
  - Lo script rifiuta un prompt che non comincia con «Paid social static ad».
  - Per una sola scena in 1:1 (rara: il 1:1 si ricava dal 9:16 su Figma) `--formato 1:1`.
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
   risposta dà l'`imageHash`, che si riusa per il rettangolo `Scena` dell'altro formato. Controlla `placedOnNodeId` in
   ogni risposta: il 03/11, con sette `nodeIds` in una chiamata, le scene sono finite slittate di un frame e la prima
   si è persa. Con più scene, una chiamata `upload_assets` per scena, oppure verifica e correggi subito i riempimenti.
3. **Due frame per ogni variante**, 1080×1920 e 1080×1080: `B<n>_ <data> - C<k> - 9:16` e `- 1:1` per la prima,
   `C<k>-2`, `C<k>-3` per le altre (la convenzione già usata nei lotti). Fondo nero, contenuto tagliato. Dentro:
   - `Scena`: rettangolo largo 1080 con l'immagine (`imageHash`, FILL). Nel 1:1 spostalo in verticale perché restino
     in quadro soggetto e grafica. Non allungarlo oltre l'altezza dell'immagine (1080×1930 per un 9:16 a 1k): con FILL
     l'immagine si ingrandisce e taglia i lati (03/11: console, biglietto e tessere tagliati). Se il visual non entra
     nella zona sicura, si rigenera la scena più compatta, non si sposta il rettangolo lasciando un buco in fondo.
   - Gli **elementi fissi dell'ad** sono quelli della scheda del cliente: CTA, prove accanto alla CTA (come un
     bollino di recensioni), logo. Vanno dove la scena è libera, anche in alto sotto il logo: mai sopra il visual
     principale.
   - **Se non c'è spazio libero per CTA e prove** (Max, 03/11, B15), prima quello che dice la scheda in «Quando non ci
     stanno», poi in quest'ordine:
     1. stringili: la CTA corta e le prove nella versione piccola della scheda, in fila invece che uno sotto l'altro;
     2. mettili insieme in una **card** nel colore di ripiego della scheda (se manca, il colore scuro del brand kit),
        angoli come i pulsanti del kit, sopra la parte meno importante della scena: mai su volti, prodotto, schermi o
        testo della scena;
     3. se nemmeno la card entra senza coprire il visual, la scena si rigenera con più spazio libero.
     Scrivi nel resoconto quale ripiego hai usato.
   - **Il pulsante della CTA si legge sempre**: su una scena chiara, se il brand kit ha solo il pulsante chiaro, usa la
     forma e il colore che la scheda indica per le scene chiare (se mancano, la stessa forma piena nel colore scuro
     del kit, con il testo chiaro), e nel resoconto proponi di aggiungere quella variante al brand kit.
   - I testi come livelli, nel font del brand kit (se manca in Figma, il sostituto indicato dal brand kit) e nei suoi
     colori, nello spazio lasciato libero dalla scena.
   - Il logo come **istanza del componente del brand kit** indicato nella scheda, non come testo.
   - Le istanze (logo, schermate dell'app) si scalano con `rescale()`, non con `resize()`: `resize` cambia il riquadro
     ma non il contenuto, e la schermata esce tagliata.
   - Un blocco di testi in auto layout va lasciato crescere (`primaryAxisSizingMode = "AUTO"`): dopo un `resize`
     resta fisso e taglia il contenuto, e i testi spariscono senza errori.
   - Le ad con più ad nello stesso lotto vanno in righe come nei lotti già fatti: 9:16 a x 4200 e 1:1 a x 5400,
     una riga ogni 2100 px per concept (C1 a y 0, C2 a y 2100...). In una pagina che ha già delle ad, la prima riga
     nuova va 2100 px sotto l'ultima.
   - **Safe zone:** quella della scheda, se ne indica una; se no quella di Meta per il 9:16, area utile x 65-1015,
     y 269-1248 (liberi il 14% in alto, il 35% in basso e il 6% ai lati). Testi, logo, CTA e soggetti
     essenziali dentro; lo sfondo può andare al vivo.
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
Il brief arriva **come la persona preferisce** (Max, 05/11): testi scritti in chat, immagini incollate, link al Google
Doc, o un misto.

1. Leggi il brief: quali ad, per ognuna testi e reference. Se manca il cliente, chiedilo insieme alle varianti.
   - **Immagini incollate:** il file di ognuna è nella riga `[Image: source: <percorso>]` del messaggio, come per la
     statica. Se non è chiaro a quale ad va un'immagine, chiedilo.
   - **Google Doc:** i brief del team hanno una scheda per lotto (`B<n>_ <data>`) e le concept numerate, ognuna con la
     sua «Concept Static Image #<n>». Il testo si legge con il connettore Google Drive della persona. Le immagini
     dentro il Doc quel connettore non le porta: chiedi di incollarle in chat, una per concept, dicendo quali
     servono. Se il connettore Drive non c'è o non apre il Doc, chiedi di incollare anche i testi.
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

## Le correzioni in chat

Correzioni e feedback si danno **solo in chat**, mai come commenti su Figma (Max, 05/11). Una correzione vale per l'ad
di adesso e non si ricorda; se non è chiaro se vale solo lì o sempre, chiedi «Vale solo qui o sempre?» (vedi «Il
feedback»). Parte quando la persona chiede di cambiare un'ad già fatta, anche nel mezzo di un giro.

1. **Quale ad.** La persona la nomina: `C2`, `C2-2`, «la 1:1 della C3», o la descrive. Trova i frame con
   `figma.sh struttura` sulla pagina del lotto (il lotto è quello del giro, o quello che dice la persona). Se il nome
   non basta a capire quale, chiedilo; le altre correzioni intanto si fanno.
2. **Quali frame.**
   - Senza formato (`C2`): i due frame di `C2`, 9:16 e 1:1.
   - Con il formato (`la 1:1 della C2`): le correzioni di **contenuto** (un testo, un colore, il logo) vanno anche
     sull'altro formato della stessa ad; quelle di **posizione o misura** solo sul frame nominato.
   - **Mai sulle altre varianti** (`C2` non tocca `C2-2` né `C2-3`) né sulle altre ad del lotto.
3. **Come.**
   - Testi, colori, posizioni, logo: con `use_figma` sui frame scelti.
   - Scena da cambiare: prompt corretto nella cartella del giro, costo detto prima («uso N crediti»), `scene.sh genera
     <cartella> <nome>`, poi `upload_assets` nel rettangolo `Scena` dei due formati, e la nuova scena anche in «Foto e
     immagini».
   - Le regole del cliente e i feedback valgono anche qui: una correzione che li viola non si fa, e dici perché.
4. Una sola `figma.sh schermate` su tutti i frame toccati, e controllo con occhio critico.
5. In chiusura: frame toccati con link, quello che non hai fatto con il motivo, crediti usati.

## Regole

- Si creano sempre **ad**: ogni prompt di scena lo dice esplicitamente, e anche le richieste ai subagenti.
- Nessuna regola di un cliente sta in questa skill: si leggono a ogni giro da Figma, dalla wiki e dai feedback.
- Prove (testimonianze, numeri, screenshot, volti di clienti o studenti) solo da materiale vero, mai generate.
- Il token di Higgsfield non si chiede mai alla CLI. Il token di Figma lo legge solo `figma.sh`, dal Portachiavi: non
  si stampa e non si cerca in altri modi.
- Scrivi in italiano, asciutto.
