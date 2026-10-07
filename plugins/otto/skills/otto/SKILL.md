---
name: otto
description: Usa questa skill quando l'utente vuole chiedere qualcosa a Otto, l'agente di LTV, o dargli un file o un'immagine, o quando la richiesta riguarda i clienti LTV (TKART, Qura, SYHO, Scuter, Taylora, Pinex...), i loro account Meta o Google Ads, i report, le campagne, i budget o la knowledge dei clienti. Trigger anche su "chiedi a Otto", "fai fare a Otto", "senti Otto", "cosa dice Otto".
---

# Lavorare con Otto

Otto è l'agente di LTV: vede gli account Meta e Google Ads dei clienti, conosce la loro knowledge,
scrive report e copy, e lavora con Drive, Notion e Slack dell'agenzia. Ci parli con gli strumenti
`chiedi_a_otto`, `risultato_otto` e `autorizza_otto`, più `prepara_consegna` per dargli un file.

## Quando passargli la richiesta

- **Dati dei clienti e delle campagne** (spesa, CPA, ROAS, lead, cosa è cambiato): chiedili a Otto.
  Non inventarli e non stimarli tu.
- **Report, analisi, copy per un cliente**: falli fare a Otto, che conosce il cliente.
- **Domande sul lavoro del team** che non riguardano i clienti: rispondi tu, senza scomodare Otto.

## Modalità Otto (`/otto on` · `/otto off` · `/otto help`)

Con `/otto on` l'utente parla solo con Otto finché non scrive `/otto off`. Mentre è attiva, ogni
messaggio arriva con un promemoria «MODALITÀ OTTO ATTIVA»: passa il messaggio a `chiedi_a_otto`
parola per parola e rispondi solo con il testo di Otto. I tre comandi li esegue il plugin: a te
arrivano con un promemoria che dice la riga da rispondere, e rispondi solo con quella. Valgono anche
scritti `/otto:otto on`, `/otto:otto off`, `/otto:otto help`: è la forma che propone il menu dei comandi.

## Come scrivergli

- Scrivi in italiano, con il cliente e il periodo espliciti («TKART, ultimi 7 giorni»).
- Otto **non vede i file dell'utente**. Un testo breve (una mail, due appunti) copialo nel
  messaggio. Un file intero si consegna (sotto).
- La conversazione continua da sola. Usa `nuova_conversazione: true` solo se l'utente cambia
  argomento da capo.

## Dare un file a Otto

Quando l'utente vuole mettere un file nella knowledge di un cliente («metti questo PDF nella
knowledge di TKART»):

1. **Cliente certo.** Se non è chiaro di quale cliente è il file, chiedilo prima: senza cliente
   Otto non archivia niente.
2. **Niente dati personali.** Non consegnare mai esportazioni con contatti, lead, ordini o
   pagamenti, per nessun cliente e in particolare per TKART (c'è un accordo sul trattamento dei
   dati). Se il file sembra uno di questi, fermati e chiedi all'utente.
   Giudica dal nome del file e da quello che dice l'utente: non aprirlo per controllare.
3. `prepara_consegna` con il nome del file - ricevi un comando `curl`.
4. Lancia il comando sostituendo `<percorso del file>` con il percorso vero, quotato correttamente per la shell (attenzione ai nomi con l'apostrofo,
   es. «Brief dell'agenzia.pdf»: usa le virgolette doppie).
   Non serve leggere il file prima.
5. Se `curl` risponde `"ok": true`, chiama `chiedi_a_otto` con la richiesta dell'utente e
   `consegna` uguale al numero (`cns_...`). Se risponde con un errore, riferiscilo così com'è.
6. Se l'errore dice «scansione», proponi all'utente di leggere tu il PDF e mandare a Otto il testo
   nel messaggio, sempre che non contenga dati personali (passo 2).

Ammessi PDF, Word, Excel, PowerPoint, CSV e testo, fino a 25 MB. A Otto arriva il **contenuto**,
non il file: grafici e immagini dentro i documenti non passano.

## Dare un'immagine a Otto

Quando l'utente vuole che Otto guardi un'immagine («valuta questa creatività», «cosa non va in
questa landing») o la usi come file («caricala come creatività su Meta»), si consegna come un file:
PNG, JPG, WebP o GIF, fino a 25 MB. A Otto arriva **l'originale**.

- **Immagine incollata nella chat:** nel messaggio c'è la riga `[Image: source: <percorso>]`. Quel
  percorso è il file: usalo nel `curl` **subito**, perché il file dura quanto la sessione.
- **Nessuna riga `source`** (per esempio nell'app desktop): chiedi all'utente di salvare
  l'immagine o di trascinare il file nella chat, così hai un percorso. Non riscrivere l'immagine tu.
- Stessa regola dei dati personali: niente screenshot di elenchi di contatti, lead, ordini o
  pagamenti.
- Il giro è lo stesso dei file (passi 3-5 sopra). Nel messaggio a `chiedi_a_otto` di' cosa deve
  farci Otto.

## Le risposte

- **Riporta la risposta di Otto tale e quale, sempre.** Non riscriverla, non riassumerla, non
  aggiungere introduzioni o commenti: l'utente vuole sentire Otto, non una tua versione di Otto.
  Se vuoi aggiungere qualcosa di tuo, mettilo dopo, separato e breve, e solo se serve davvero.
- Se ricevi un **numero di pratica** (`run_...`), Otto sta ancora lavorando: dillo all'utente, aspetta
  un minuto e richiama `risultato_otto` con quel numero. Ripeti finché arriva la risposta.
- Se Otto **chiede un'autorizzazione**, spiega all'utente cosa sta per fare e **chiedi a lui**
  sì o no. Poi usa `autorizza_otto`. Non autorizzare mai da solo.
- Se Otto non è raggiungibile o risponde con un errore, dillo all'utente così com'è. Se il token non
  funziona, l'utente deve chiedere a Max un token nuovo.
