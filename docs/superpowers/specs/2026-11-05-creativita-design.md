# Plugin creativita - design per l'uscita al team (05/11/2026)

Nasce dalla sessione del 05/11 con Max, dopo il giro B15. Rifà il piano dall'obiettivo: cosa deve fare il plugin
quando lo scarica tutto il team. Il design del 03/11 (`2026-11-03-creativita-design.md`, qui accanto) resta valido
dove questo documento non dice altro: lì ci sono il giro di una creatività, le convenzioni di Figma, i due ingressi,
il giro veloce e i soldi. Le parole del plugin stanno in `plugins/creativita/CONTEXT.md`.

## Perché

Il plugin funziona: Max ci ha fatto i lotti B6-B15 di Learnn. Adesso deve passare dalle mani di Max a quelle del team.
Ognuno lo installa, si collega e fa ad nel brand del cliente senza Max accanto. Quello che il team impara facendo le
ad deve restare: le persone danno feedback, il plugin se li ricorda, e quelli buoni arrivano a tutti.

## Obiettivo (Max, 05/11)

- Tutto il team scarica il plugin con un comando e si collega facilmente a Figma e a Higgsfield.
- Il plugin ha tutte le istruzioni e le skill per generare le immagini come devono essere.
- È collegato alla knowledge di ogni cliente nella wiki: materiali, linee guida, copy, skill del cliente.
- Esce solo con Learnn, ma funziona per qualunque cliente senza toccare il codice.
- Il team crea e dà feedback. Il plugin li ricorda.
- Il plugin si aggiorna per tutti da solo.

## Decisioni di Max (05/11)

1. **Otto non fa niente.** Claude legge la wiki di Otto con gli strumenti di lettura della knowledge, e basta: nessuna
   domanda a Otto e nessun lavoro fatto da Otto. Si toglie «chiedi a Otto le vecchie creatività»: le vecchie
   creatività le passa la persona in chat, oppure si guardano i lotti già fatti su Figma.
2. **Un punto d'ingresso fisso per cliente:** `clienti/<cliente>/creativita.md` nella wiki. Il giro lo apre per primo.
   Dice dove sono il file Figma del cliente, i materiali, le linee guida, le regole del copy e le skill del cliente.
   Un cliente è **pronto** quando ha la scheda e il brand kit su Figma. Per un cliente non pronto il giro si ferma e
   dice cosa manca.
3. **Correzioni e feedback si danno solo in chat a Claude.** Niente commenti su Figma e niente file Figma dei feedback.
   - **Correzione:** vale solo sul momento, per un'ad o un lotto («nella C2 il titolo più grande»). Claude la sistema
     su Figma, sul frame indicato, e non la ricorda.
   - **Feedback:** vale sempre, per i giri futuri («mai testo sopra la foto»). Il plugin lo ricorda.
   - Se non è chiaro quale dei due è, Claude chiede in una riga: «Vale solo qui o sempre?».
4. **I feedback per tutti entrano nel plugin a mano.** Il plugin non manda niente a nessuno: né Slack, né webhook, né
   un comando che prepara un messaggio. Max sceglie quali feedback valgono per il team e li mettete a mano nel
   `feedback.md` del plugin. Arrivano a tutti con l'aggiornamento automatico.
5. **Account Higgsfield:** di base quello dell'agenzia, lo stesso per tutti. Chi usa il plugin può rifare il login e
   cambiarlo (`/creativita account` spiega come, già oggi).
6. **Il brief si dà come si vuole:** testi scritti in chat, immagini incollate, link al Google Doc del brief. Dal Doc
   Claude legge il testo con il connettore Google Drive della persona. Le immagini dentro il Doc quel connettore non le
   porta: Claude chiede di incollarle in chat. Composio esce dal plugin.
7. **Higgsfield con la password condivisa:** l'account dell'agenzia si apre con email e password, che la persona
   chiede a Max. La configurazione guidata lo dice; la password non si scrive mai in nessun file.
8. **Fuori da questo piano:** il brand kit per i clienti nuovi (progetto a parte) e il giro delle correzioni dai
   commenti di Figma.

## Le due memorie dei feedback

- **Feedback del team:** `plugins/creativita/feedback.md`, nel repo. Si legge a ogni giro e vince su brand kit, wiki e
  reference, come oggi. Lo cambiano solo Max e chi lavora sul repo, a mano. Le sezioni restano «Per tutti i clienti» e
  «Per cliente».
- **Feedback personale:** un file sul computer di chi l'ha dato, con le stesse sezioni. Quando la persona dà un
  feedback, Claude lo scrive lì e dice in una riga cosa ha salvato. Si legge a ogni giro insieme a quello del team.
  Se i due si contraddicono, per quella persona vince il suo, e nel resoconto Claude lo dice.
- «Quali indicazioni hai?» mostra tutte e due, separate.

## Cosa cambia rispetto a oggi

- La skill non scrive più in `feedback.md` del plugin: scrive nel file personale. La riga «il file resta solo se finisce
  nel repo» sparisce.
- La sezione «Il giro delle correzioni» (commenti di Figma) esce dalla skill e dalla sua descrizione. Si aggiunge la
  correzione in chat: la persona nomina l'ad (per esempio «C2» o «la 1:1 della C3») e Claude la sistema con gli stessi
  strumenti del giro, rigenerando la scena solo se la correzione riguarda la scena (costo detto prima).
- Il passo 2 della skill parte da `clienti/<cliente>/creativita.md` invece di cercare il link di Figma nella cartella.
- Learnn ha la sua scheda `clienti/learnn/creativita.md`, scritta partendo da quello che c'è già nella wiki
  (`brand.md`, `creativita-repo-learnn.md`, `scheda.md`, i file sulle creatività) e dal file Figma
  `LRhzTaDLREM1sSKAJKGoMV`.
- Dal design del 03/11 si toglie la scelta `chiedi_a_otto`.

## Obiettivi

- Una persona del team, con il plugin installato e la configurazione guidata fatta, porta una statica o un brief di
  Learnn fino alle ad su Figma senza chiedere niente a Max.
- Una correzione data in chat cambia solo l'ad indicata.
- Un feedback dato in chat cambia i giri successivi di quella persona, anche dopo un aggiornamento del plugin.
- Aggiungere un cliente vuol dire scrivere la sua scheda e preparare il brand kit, non cambiare il plugin.

## Non obiettivi

- Brand kit per i clienti nuovi, estrazione dalle vecchie creatività.
- Raccolta automatica dei feedback del team.
- Commenti su Figma, in lettura o in risposta.
- Tutto quello che era già fuori il 03/11: video, caroselli, pubblicazione su Meta, Drive.

## Anti-obiettivi

- Otto che riceve richieste o fa lavoro durante un giro.
- Un feedback personale perso a un aggiornamento del plugin.
- Un feedback di una persona che finisce nei giri di tutti senza che Max l'abbia scelto.
- Una correzione su un'ad che cambia anche le altre varianti o le altre ad del lotto.
- Regole di un cliente scritte nella skill o negli script.

## Vincoli

- Il repo del plugin (`LTVBEAT/otto-claude`) si installa da `raw.githubusercontent.com`: va trattato come leggibile da
  chiunque. Niente indirizzi, token o dati di clienti fuori da quello che c'è già.
- La lettura della wiki usa gli strumenti di lettura del plugin Otto: per usare creativita serve anche il plugin Otto
  installato con il suo token. La configurazione guidata lo controlla già.
- Scrivere nella wiki (la scheda di Learnn) passa dallo strumento di scrittura della knowledge, che apre una finestra
  di conferma: decide la persona.
- `installa.sh` installa già creativita e accende l'aggiornamento automatico del marketplace `ltvbeat` (verificato il
  05/11). L'aggiornamento arriva a tutti solo dopo il merge su main, che lancia Max.
- Restano i vincoli del 03/11: posto Full su Figma (Sofia ed Elisa da verificare), font del cliente presenti in Figma,
  abbonamento Claude Code di ognuno.

## Scelte mie, da controllare

- Il feedback personale sta in `${CLAUDE_PLUGIN_DATA}` (la cartella dati del plugin, già usata dall'hook), che
  sopravvive agli aggiornamenti; non nella cartella del plugin, che si riscrive.
- Le regole che oggi nella skill sono solo di Learnn passano nella scheda `clienti/learnn/creativita.md`, e la skill le
  legge da lì: il testo della CTA («Inizia gratis»), il componente del logo, il colore della card di ripiego, il
  Trustpilot come elemento fisso accanto alla CTA. Restano nel plugin le convenzioni di tutti: la safe zone di Meta, la
  disposizione dei lotti su Figma (colonne e righe), il modello dei brief del team.
- La scheda del cliente ha quindi questi campi: file Figma, materiali e dove stanno, linee guida, regole del copy,
  skill del cliente, elementi fissi dell'ad (CTA, prove, logo) e cosa fare quando non ci stanno.
- I comandi `commenti`, `rispondi` e `reazione` escono anche da `figma.sh`, non solo dalla skill: il team non deve
  trovare un modo di lavorare che non si usa.
- La scheda di Learnn si scrive nella wiki prima del merge, e la versione in `plugin.json` sale, se no l'aggiornamento
  automatico non parte.
- Nel conflitto tra feedback personale e feedback del team vince quello personale, per chi l'ha dato.
- I feedback «Per cliente» restano nel `feedback.md` del plugin: sono feedback dati guardando le ad, non regole del
  cliente, e le regole del cliente restano nella wiki.
- Un cliente non pronto ferma il giro invece di andare avanti a metà.

## Lasciato a chi costruisce

Come la skill riconosce un'ad nominata in chat, se una correzione tocca uno o tutti e due i formati della stessa ad,
come si collauda il giro su un computer pulito prima di darlo al team.
