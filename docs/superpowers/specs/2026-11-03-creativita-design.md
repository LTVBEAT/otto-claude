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
   browser) e si vede il progetto condiviso **«Giotto»** del team Beat Performance.
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
5. **L'immagine:** Higgsfield genera la scena di ogni proposta (GPT Image 2, 1k, senza testo, con la statica come
   reference e il prompt che evita di rifarla uguale). Prima di spendere Claude mostra il costo e aspetta l'ok.
6. **Su Figma:** nel file del cliente c'è la pagina **Brand kit**. Claude compone ogni proposta tenuta in due frame,
   9:16 (1080×1920) e 1:1 (1080×1080), a livelli: scena, copy negli stili di testo del cliente, logo ed elementi del kit.
7. **Ritocco:** il team sistema a mano su Figma ed esporta il PNG.

## Il brand kit su Figma

- Un file per cliente, `Giotto - <Cliente>`, nel progetto «Giotto». Pagina **Brand kit**: logo (varianti), palette come
  stili colore, font come stili di testo, elementi ricorrenti (bollini, icone, cornici, pattern) e immagini vere.
- Si prepara una volta per cliente e si riusa a ogni giro.
- Elementi: da quello che dà il cliente; altrimenti **estratti dalle sue vecchie creatività**, che Claude chiede a Otto.
  Gli elementi estratti si mostrano in chat ed entrano nella pagina solo dopo l'ok della persona.

## Soldi

Tetti del giro: **6 crediti per proposta**, **18 per giro**, qualità media di default, costo mostrato prima, nessun
nuovo tentativo automatico. Senza un server li fa rispettare la skill: è un paletto più morbido di quello dello studio,
accettato insieme alla scelta di non avere un server.

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
  MCP di Figma: 200 chiamate al giorno con un posto Full.
- Il font del cliente deve esistere in Figma: i Google Fonts ci sono, i proprietari vanno caricati nel team.
- Le istruzioni e le skill dei clienti devono stare nella wiki di Otto. Per Learnn oggi sono soprattutto su GitHub:
  vanno portate nella wiki prima del pilota.
- La modalità usa l'abbonamento Claude Code di ognuno.

## Scelte mie, da controllare

- Le vecchie creatività del cliente si chiedono a Otto (`chiedi_a_otto`), che legge gli account Meta; la persona può
  anche passarle in chat.
- Il registro dei giri è il file Figma del cliente: una pagina per giro, `Giro <data> - <statica>`. Prima di proporre,
  Claude guarda le pagine già fatte per non ripetersi.

## Lasciato a chi costruisce

Come la fascia legge la fase durante il turno, quali comandi della CLI Higgsfield danno costo, reference e saldo, come si
ritagliano gli elementi in Figma.
