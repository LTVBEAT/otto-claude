---
name: otto
description: Usa questa skill quando l'utente vuole chiedere qualcosa a Otto, l'agente di LTV, o quando la richiesta riguarda i clienti LTV (TKART, Qura, SYHO, Scuter, Taylora, Pinex...), i loro account Meta o Google Ads, i report, le campagne, i budget o la knowledge dei clienti. Trigger anche su "chiedi a Otto", "fai fare a Otto", "senti Otto", "cosa dice Otto".
---

# Lavorare con Otto

Otto è l'agente di LTV: vede gli account Meta e Google Ads dei clienti, conosce la loro knowledge,
scrive report e copy, e lavora con Drive, Notion e Slack dell'agenzia. Ci parli con gli strumenti
`chiedi_a_otto`, `risultato_otto` e `autorizza_otto`.

## Quando passargli la richiesta

- **Dati dei clienti e delle campagne** (spesa, CPA, ROAS, lead, cosa è cambiato): chiedili a Otto.
  Non inventarli e non stimarli tu.
- **Report, analisi, copy per un cliente**: falli fare a Otto, che conosce il cliente.
- **Domande sul lavoro del team** che non riguardano i clienti: rispondi tu, senza scomodare Otto.

## Come scrivergli

- Scrivi in italiano, con il cliente e il periodo espliciti («TKART, ultimi 7 giorni»).
- Otto **non vede i file dell'utente**: se serve un testo o un dato che sta qui, copialo nel messaggio.
- La conversazione continua da sola. Usa `nuova_conversazione: true` solo se l'utente cambia
  argomento da capo.

## Le risposte

- **Riporta la risposta di Otto all'utente.** Se è un testo da mandare a un cliente (report, mail,
  copy), riportalo **così com'è**, senza riscriverlo né riassumerlo.
- Se ricevi un **numero di pratica** (`run_...`), Otto sta ancora lavorando: dillo all'utente, aspetta
  un minuto e richiama `risultato_otto` con quel numero. Ripeti finché arriva la risposta.
- Se Otto **chiede un'autorizzazione**, spiega all'utente cosa sta per fare e **chiedi a lui**
  sì o no. Poi usa `autorizza_otto`. Non autorizzare mai da solo.
- Se Otto non è raggiungibile o risponde con un errore, dillo all'utente così com'è. Se il token non
  funziona, l'utente deve chiedere a Max un token nuovo.
