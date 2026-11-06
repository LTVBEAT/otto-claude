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
   cambiarlo (`/creativita account` spiega come, già oggi). **Aggiornata il 06/11 (Max): va bene qualsiasi account, il plugin non
   propone di cambiarlo.**
6. **Il brief si dà come si vuole:** testi scritti in chat, immagini incollate, link al Google Doc del brief. Dal Doc
   Claude legge il testo con il connettore Google Drive della persona. Le immagini dentro il Doc quel connettore non le
   porta: Claude chiede di incollarle in chat. Composio esce dal plugin.
7. **Higgsfield con la password condivisa:** l'account dell'agenzia si apre con email e password, che la persona
   chiede a Max. La configurazione guidata lo dice; la password non si scrive mai in nessun file. Dal 06/11 vale solo per chi non ha già un account.