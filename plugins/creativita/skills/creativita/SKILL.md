---
name: creativita
description: Crea ad statiche per un cliente LTV/Beat, nel suo brand kit su Figma, con le scene generate su Higgsfield e montate su Figma. Usala quando la persona passa una statica da riadattare per un cliente, o un brief già pronto con testi e reference da realizzare, e quando la creazione creatività è accesa (/creativita on) e arriva una statica o un brief.
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
  scriverlo nella scheda del cliente. Apri il file con l'MCP di Figma (`create_session`, poi `get_metadata` senza nodo).
  Il brand kit è la pagina **«Brand kit»**: «Asset · 01 Logo», «02 Esperti», «03 Immagini», «04 Terze parti» e «Linee
  guida». Le linee guida si guardano sezione per sezione con `get_screenshot` (`maxDimension` 1440, scarica con curl
  in una cartella temporanea e leggi l'immagine). Ne ricavi palette con codici e ruoli, divieti, font, varianti del
  logo, foto ed elementi disponibili.
- **Wiki, sezione creatività del cliente.** Nella cartella del cliente ci sono le istruzioni e le **skill del
  cliente** per le creatività (per Learnn, per esempio, i file sulle creatività e la knowledge portata da GitHub):
  trovale con `elenca_knowledge` e `cerca_nella_knowledge`, leggile e **seguile nei momenti in cui servono**: regole dei
  testi quando scrivi i copy, regole visive quando scrivi i prompt, regole di formato quando monti su Figma.
- Il brand kit su Figma vince sul visual, la wiki su tono e testi. Se si contraddicono, scegli la regola più recente e
  scrivilo nel resoconto.
- Nel resoconto finale scrivi in due righe il brand usato: colori con codici, font, elementi.
- Se il cliente non ha un brand kit su Figma, dillo e fermati: si prepara prima.

### 3. Due analisi in parallelo (solo statica)

Lancia insieme, nello stesso messaggio, i subagenti **`creativita:format-concept`** e **`creativita:visual-testi`**.
A tutti e due di' che si sta creando un'ad statica per Meta (9:16 e 1:1) e passa: il percorso della statica, il
cliente, il riassunto del brand kit (palette con ruoli e divieti, font, logo, elementi e foto), le regole e le skill
del cliente per le creatività, il materiale vero e il numero di varianti.

### 4. Le varianti

Unisci le analisi in tante varianti quante richieste, senza chiedere conferma. Per ognuna:
- **Idea:** format e significato riadattati al materiale vero, e perché non è una copia.
- **Scena:** il prompt per l'immagine, in inglese. **Comincia sempre dicendo che è un'ad**: «Background scene for a
  paid social static ad (Meta, 9:16) for <cliente>, <cosa vende>». Dentro: soggetto e composizione, i colori del brand
  kit con codici e ruolo, lo stile, gli spazi vuoti per headline, testi, CTA e logo, la richiesta di non rifare la
  composizione della reference.
- **I testi vanno su Figma, la grafica su Higgsfield** (Max, 03/11). Testi = headline, sottotitoli, testi brevi, CTA,
  logo: livelli su Figma, mai nella scena. Grafica = quello che non si può fare bene come testo, anche se contiene
  lettere o numeri: un «-40€» gigante in 3D che crolla su una scrivania, un bollino disegnato, una scritta su un
  oggetto. Se un elemento ha volume, luce o interagisce con la scena, è grafica e va nel prompt.
- **Copy:** headline, testi brevi e CTA, nel tono e con le regole del cliente, con il font del brand kit.
- **Dal brand kit:** loghi, elementi e foto vere da usare nel montaggio. Foto vere, schermate dell'app,
  testimonianze e numeri di prova non si generano.

### 5. Le scene su Higgsfield

- Modello: GPT Image 2 (`gpt_image_2`, qualità `medium`, 1k, 9:16: 1 credito a scena) di default; GPT Image 2.5
  (`gpt_image_2_5 --variant sunburst --quality max`, 1k: 5 crediti a scena) se la persona lo chiede. La statica o la
  reference del brief va come `--image-references <percorso>`.
- **Il costo si dice, non si chiede:** `higgsfield generate cost`, poi una riga «uso N crediti» e si parte.
- Tetti, che restano: **6 crediti per ad** (tutte le sue varianti) e **18 per giro**. Se un'ad li supererebbe, non
  lanciarla e chiedi.
- `higgsfield generate create ... --wait`, una scena alla volta; scarica l'immagine in una cartella temporanea.
- **Controlla ogni scena con occhio critico:** numeri e lettere della grafica (un «4» che sembra un «7», una «€»
  deformata), colori rispetto al brand, mani e volti, oggetti non richiesti. Se c'è un difetto chiaro, **una**
  rigenerazione automatica con il prompt corretto, dentro i tetti; se resta, la scena va su Figma lo stesso e il
  difetto si scrive nel resoconto.
- Se la CLI risponde «No workspace selected», fermati e chiedi di scegliere il workspace con
  `higgsfield workspace list` e `higgsfield workspace set <id>`.

### 6. Su Figma

Prima di scrivere su Figma carica le istruzioni obbligatorie dell'MCP di Figma (`figma-use` e
`figma-generate-design`, anche come risorse `skill://figma/...`). Poi, nel file del cliente:

1. **Pagina del lotto** `B<n>_ <data>` (dal brief, o il lotto successivo all'ultimo): se non c'è, creala.
2. **Riquadro «00 – Asset (foto e componenti)»** in alto a sinistra, con un rettangolo per ogni scena (nome
   parlante, misura dell'immagine). Carica la scena con `upload_assets` puntando a quel rettangolo (`nodeIds`) e
   inviala con curl in multipart: la risposta dà l'`imageHash`.
3. **Due frame per ogni variante**, 1080×1920 e 1080×1080: `B<n>_ <data> - C<k> - 9:16` e `- 1:1` per la prima,
   `C<k>-2`, `C<k>-3` per le altre (la convenzione già usata nei lotti). Fondo nero, contenuto tagliato. Dentro:
   - `Scena`: rettangolo largo 1080 con l'immagine (`imageHash`, FILL). Nel 1:1 spostalo in verticale perché restino
     in quadro soggetto e grafica.
   - I testi come livelli, nel font del brand kit (se manca in Figma, il sostituto indicato dal brand kit) e nei suoi
     colori, nello spazio lasciato libero dalla scena.
   - Il logo come **istanza del componente del brand kit** (per Learnn «Logo Learnn / Bianco»), non come testo.
4. Guarda i frame con `get_screenshot`: testi tagliati, sovrapposti alla grafica o fuori dalla zona sicura si
   correggono subito.

### 7. Il resoconto

Uno solo, alla fine: link alla pagina e ai frame su Figma, schermate, crediti usati, brand usato in due righe, difetti
rimasti e scelte fatte da te (materiale, regole in conflitto). La persona sceglie le varianti dentro Figma.

## Ingresso dal brief

La persona passa un brief già pronto: testi (headline, testi, CTA) e una o più reference, a volte già divise in più ad.

1. Leggi il brief: quali ad, per ognuna testi e reference. Se manca il cliente, chiedilo insieme alle varianti.
   - I brief del team sono Google Doc con una scheda per lotto (`B<n>_ <data>`) e le concept numerate. Il testo si
     legge con il connettore di Google Drive. Le reference sono immagini dentro il Doc e la lettura del testo non le
     porta: si prendono con Composio, `GOOGLEDOCS_GET_DOCUMENT_BY_ID` con `includeTabsContent` e l'account
     massimo.cardini@ltvalue.it. Nella scheda giusta, l'immagine che segue «Concept Static Image #<n>» è un
     `inlineObjectElement`, e il suo `imageProperties.contentUri` si scarica con curl.
   - Il lotto del brief è anche il nome della pagina Figma in cui vanno le ad (`B<n>_ <data>`).
2. L'unica domanda: quante varianti per ogni ad (1, 2 o 3).
3. Brand come al passo 2.
4. Niente subagenti e niente idee nuove: i testi del brief **si usano così come sono**. Se un testo va contro le regole
   del cliente o non entra nel formato, usalo comunque e segnalalo nel resoconto con la correzione proposta. Le note
   del brief (impianto, scena, persona) entrano nel prompt.
5. Da qui come i passi 4 (solo la scena), 5, 6 e 7.

## Regole

- Si creano sempre **ad**: ogni prompt di scena lo dice esplicitamente, e anche le richieste ai subagenti.
- Nessuna regola di un cliente sta in questa skill: si leggono a ogni giro da Figma e dalla wiki.
- Prove (testimonianze, numeri, screenshot, volti di clienti o studenti) solo da materiale vero, mai generate.
- Il token di Higgsfield non si chiede mai alla CLI.
- Scrivi in italiano, asciutto.
