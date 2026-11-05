# Plugin creativita - design (03/11/2026)

Nasce dalla sessione del 03/11 con Max. Sostituisce il disegno «plugin Giotto con server MCP» dello stesso giorno: Max
ha chiesto se il server servisse davvero, e non serve. Il ragionamento sul format viene dal passo del concetto di Giotto
(`codice/agente-creativita/docs/superpowers/specs/2026-11-02-concetto-design.md`).

## Perché

Giotto non può scrivere su Figma: l'MCP di Figma rifiuta i client non approvati (prova del 03/11: la registrazione
OAuth di un client «Giotto» risponde 403). Claude Code invece è un client approvato. Con il plugin, ognuno del team usa
il suo Claude Code, collegato a Figma e a Higgsfield, e le creatività arrivano su Figma a livelli, pronte da ritoccare.

## Un plugin a sé: creativita (Max, 03/11)

La creazione creatività è un processo suo e **non c'entra con Otto**: plugin `creativita`, nel marketplace del team
`LTVBEAT/otto-claude`, con i suoi comandi e la sua fascia. Nessun server nuovo: la wiki dei clienti si legge con gli
strumenti di lettura della knowledge che oggi stanno nel plugin Otto (installato a parte), Figma e Higgsfield si
collegano direttamente nel Claude Code di ognuno.

## Comandi

- `/creativita on` accende la creazione; `/creativita off` la spegne; `/creativita help` spiega i comandi.
  Una modalità alla volta: accendere la creazione spegne la modalità Otto, e se Otto si riaccende dopo, vince Otto.
- `/creativita configura`: la configurazione guidata (sotto).
- `/creativita account`: dice con quale account Higgsfield si è collegati e permette di cambiarlo (esci ed entra).

## Il segnale (Max, 03/11)

Con la creazione accesa, sopra il prompt c'è una fascia «🎨 Creazione creatività - <fase>»: analisi, proposte, scena,
figma. La fase si aggiorna anche a metà turno.

## La configurazione guidata

Installato il plugin, `/creativita configura` accompagna la persona un passo alla volta, controlla ogni collegamento
prima del successivo e alla fine dice cosa funziona e cosa manca:

1. **Wiki dei clienti:** il plugin Otto è installato con il token e la wiki si legge.
2. **Figma:** il plugin ufficiale di Figma è installato, il login è fatto con l'account della persona (un clic nel
   browser) e c'è un posto Full nel team **Beat Performance**, dove stanno le cartelle dei clienti.
3. **Higgsfield:** la CLI è installata (`npm i -g @higgsfield/cli`) e il login è fatto (`higgsfield login`, nel browser).
   Tutti entrano con l'**unico account Higgsfield dell'agenzia** (Max, 03/11: un solo account, niente account
   personali né workspace separati). Cambiarlo dev'essere facile: `/creativita account`.

## Il giro di una creatività (parole di Max)

1. **La statica.** La persona passa in chat una statica qualsiasi e dice per quale cliente riadattarla.
2. **Quante proposte:** Claude lo chiede con il riquadro delle domande, da 1 a 3.
3. **Due analisi separate, due subagenti in parallelo:**
   - **Format e concept:** che tipo di creatività è, com'è costruita, cosa vuole dire e perché funziona. Da qui: come
     riadattarla al cliente **senza rifarla identica**.
   - **Visual e testi:** colori, composizione, immagini, elementi, gerarchia e tono dei testi. Da qui: come rifarli
     **sul branding del cliente**, colori della scena compresi.
4. **Le proposte:** ognuna ha l'idea adattata, la scena da generare nei colori del cliente e i copy (headline, testi
   brevi, CTA) nel tono e con le regole del cliente lette dalla wiki di Otto.
5. **L'immagine:** Higgsfield genera la scena di ogni proposta (GPT Image 2, 1k; GPT Image 2.5 Sunburst su richiesta),
   con la statica come reference e il prompt che evita di rifarla uguale. Il costo si dice, non si chiede.
6. **Su Figma:** nel file del cliente c'è la pagina **Brand kit**. Claude compone ogni proposta tenuta in due frame,
   9:16 (1080×1920) e 1:1 (1080×1080), a livelli: scena, copy negli stili di testo del cliente, logo ed elementi del kit.
7. **Ritocco:** il team sistema a mano su Figma ed esporta il PNG.

## Il brand kit e i file su Figma (Max, 03/11)

- Nel team Figma **Beat Performance** c'è una cartella per cliente (Learnn, Tkart, SYHO, Pinex Capital...), più
  «Template». Nella cartella del cliente c'è il suo file delle creatività (per Learnn «Creatività Adv - Learnn»).
- Il file ha la pagina **«Brand kit»**, preparata con il cliente: «Asset · 01 Logo», «02 Esperti», «03 Immagini»,
  «04 Terze parti» e «Linee guida» (colori con ruoli e divieti, per esempio il viola del sito non va nelle creatività;
  logo e varianti; font). **È il brand che si usa per generare**: colori, stile ed elementi entrano nel prompt della
  scena, foto e loghi veri entrano nella composizione.
- Le creatività stanno in una pagina per brief, `B<n>_ <data>` (per Learnn «B6_ 26.10.2026»), con i frame
  `B<n>_ <data> - C<k> - 9:16` e `- 1:1`. Il giro segue questa convenzione. Il riquadro «00 – Asset» dei primi lotti
  non si fa più: nella pagina del brief solo creatività finite (Max, 03/11).
- Il file ha anche la pagina **«Foto e immagini»** (Max, 03/11): a brief finito ci vanno le scene generate, una riga
  per brief, con lo stesso `imageHash` dei frame.
- Il brand kit cresce piano piano: gli elementi che mancano si estraggono anche dal sito del cliente e vanno in un
  riquadro «Da verificare» del brand kit, che non si usa finché il team non lo svuota (Max, 03/11).
- L'MCP di Figma non elenca le cartelle di un team: il link del file del cliente va scritto nella sua scheda della wiki
  di Otto; se manca, il giro lo chiede.
- Se un cliente non ha ancora il brand kit, si prepara prima (Sezione 4), anche estraendo gli elementi dalle sue
  vecchie creatività, con l'ok della persona su ogni elemento.

## Due ingressi (Max, 03/11)

- **Statica da riadattare:** il giro completo descritto sopra.
- **Brief pronto:** testi e reference già decisi. Niente subagenti né proposte nuove: i testi si usano come sono
  (si segnala solo quello che va contro le regole del cliente), la reference va a Higgsfield, poi costo, scena e Figma.
- In tutti e due i casi **ogni prompt dice esplicitamente che si sta creando un'ad** (statica per Meta, 9:16 e 1:1).

## Il giro veloce (Max, 03/11, dopo la prima prova)

- **Una sola domanda:** quante varianti per ogni ad (1, 2 o 3). Poi si va fino a Figma senza fermarsi.
- Niente conferma del brand: brand kit su Figma e wiki si danno per corretti, si leggono sempre e si usano. Nella wiki
  la sezione creatività del cliente contiene istruzioni e **skill del cliente**, da usare nei momenti in cui servono
  (copy, prompt, montaggio).
- Niente ok su proposte, prompt, costo e scene: il costo si dice («uso N crediti»), le scene si controllano con occhio
  critico (una rigenerazione automatica su un difetto chiaro) e vanno tutte su Figma. **La persona
  sceglie le varianti dentro Figma** (`C<k>`, `C<k>-2`, `C<k>-3`).
- I testi (headline, testi, CTA, logo) sono livelli su Figma; la grafica, anche con lettere o numeri come un «-40€» in
  3D, si genera su Higgsfield.
- Un solo resoconto alla fine: link Figma, schermate, crediti, brand usato, difetti e scelte fatte.

## Soldi

Modello: GPT Image 2.5 Sunburst, qualità xhigh, 1k (2,5 crediti a scena). Nessun tetto di crediti (Max, 03/11): il
costo si dice prima di partire.

## Obiettivi

- Installato il plugin e fatta la configurazione guidata, una persona del team arriva da «riadattami questa statica per
  X» a frame Figma ritoccabili nel brand del cliente.
- Si vede sempre quando la modalità creatività è accesa e in che fase si è.

## Non obiettivi

- Non tocca lo studio di Giotto, né il suo brand kit, né il percorso Canva.
- Niente video, caroselli o formati oltre 9:16 e 1:1. Non pubblica su Meta e non carica sul Drive.

## Anti-obiettivi

- Una copia della statica con cambiato solo il logo, o un'ad che ha perso il concept.
- Prove inventate: testimonianze, numeri, screenshot e volti di clienti solo da materiale vero.
- Crediti spesi senza che la persona veda prima il costo.
- Account Figma condivisi o client finti verso Figma.
- Un brand kit riempito di elementi estratti male senza che nessuno li abbia guardati.

## Vincoli

- Figma: posto **Full** per scrivere nel progetto condiviso. Confermato solo quello di Max; Sofia ed Elisa da verificare.
  MCP di Figma: 200 chiamate al giorno e 10 al minuto con un posto Full sul piano Pro. Per questo le letture passano
  dall'API REST (`scripts/figma.sh`): nessun tetto giornaliero, 15 al minuto per file e render, 50 per i commenti. Serve
  un token personale Figma a 90 giorni nel Portachiavi di ognuno; senza, il giro legge con l'MCP. Dettagli nel design
  `2026-11-03-creativita-api-figma-design.md` (qui accanto) e piano in `docs/superpowers/plans/`.
- Il font del cliente deve esistere in Figma: i Google Fonts ci sono, i proprietari vanno caricati nel team.
- Le istruzioni e le skill dei clienti devono stare nella wiki di Otto. Per Learnn oggi sono soprattutto su GitHub:
  vanno portate nella wiki prima del pilota.
- La modalità usa l'abbonamento Claude Code di ognuno.

## Scelte mie, da controllare

- ~~Le vecchie creatività del cliente si chiedono a Otto (`chiedi_a_otto`), che legge gli account Meta; la persona può
  anche passarle in chat.~~ Tolta il 05/11: Otto non fa niente nel giro (spec `2026-11-05-creativita-design.md`).
- Il registro dei giri è il file Figma del cliente: le pagine dei lotti `B<n>_ <data>`. Prima di proporre, Claude
  guarda i lotti già fatti per non ripetersi.

## Lasciato a chi costruisce

Come la fascia legge la fase durante il turno, quali comandi della CLI Higgsfield danno costo, reference e saldo, come si
ritagliano gli elementi in Figma.
