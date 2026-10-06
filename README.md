# Otto in Claude Code

Parla con **Otto**, l'agente di LTV, direttamente da Claude Code: account Meta e Google Ads dei
clienti, report, copy, knowledge. È lo stesso Otto di Slack.

## Installazione (1 minuto)

**Ti serve:** Claude Code e il tuo **token personale di Otto**, che ti dà Max.

**1.** Apri l'app **Terminale** del Mac, incolla questa riga e premi Invio:

```
curl -fsSL https://raw.githubusercontent.com/LTVBEAT/otto-claude/main/installa.sh | bash
```

**2.** Quando chiede il token, incollalo e premi Invio. Mentre incolli non vedi niente: è normale.
Il token resta nel Portachiavi del Mac, non dovrai più inserirlo.

**3.** Chiudi e riapri Claude Code (terminale o app) e scrivi:

> chiedi a Otto come vanno gli account di TKART questa settimana

Fatto. Lo script è leggibile qui sopra, in `installa.sh`: aggiunge il catalogo, installa il plugin,
accende gli aggiornamenti automatici, controlla che il token funzioni e lo salva.

<details>
<summary>Preferisci farlo a mano, da dentro Claude Code?</summary>

```
/plugin marketplace add LTVBEAT/otto-claude
/plugin install otto@ltvbeat
/plugin configure otto@ltvbeat
```

L'ultimo comando chiede il token.
</details>

## Come si usa

Scrivi normalmente a Claude. Quando la richiesta riguarda clienti, campagne o report, Claude la
passa a Otto da solo. Puoi anche dirlo esplicitamente: «chiedi a Otto…», «fai fare a Otto…».

- **Parlare solo con Otto**: scrivi `/otto on`. Da lì ogni messaggio va a Otto e la risposta è la
  sua, tale e quale. Con `/otto off` torni a parlare con Claude. Vale per la finestra in cui lo
  scrivi, non per le altre.
- **Lavori lunghi** (un report): Otto ci mette qualche minuto. Claude ti avvisa e recupera la
  risposta quando è pronta.
- **Azioni sugli account** (mettere in pausa, cambiare budget): Otto chiede il permesso e Claude
  lo chiede **a te** prima di dire sì.
- **La conversazione continua**: Otto ricorda cosa vi siete detti. Per ripartire da zero, dillo:
  «nuova conversazione con Otto».

## Cosa puoi chiedere

Esempi di richieste a Otto:

- «Chiedi a Otto come vanno gli account di TKART questa settimana»
- «Metti nella knowledge di TKART il brief che ho in Scaricati»
- «Fai fare a Otto un report di Qura degli ultimi 30 giorni»
- «Cosa dice Otto sui budget di SYHO?»

## Problemi

| Cosa vedi | Cosa fare |
|---|---|
| «Token mancante o non valido» | chiedi a Max un token nuovo e rilancia il comando di installazione |
| «Otto non è raggiungibile» | riprova tra qualche minuto; se dura, avvisa Max |
| Claude non trova Otto | chiudi e riapri Claude Code; se ancora niente, rilancia il comando di installazione |

## Aggiornare

Se hai installato con il comando qui sopra, Otto si aggiorna da solo: Claude Code controlla poco
dopo l'avvio e la versione nuova parte alla sessione dopo (o subito con `/reload-plugins`).

Se l'hai installato prima del 06/10/2026, accendi gli aggiornamenti automatici una volta sola: in
Claude Code `/plugin` → scheda **Marketplaces** → `ltvbeat` → **Enable auto-update**. Oppure
aggiorna a mano quando vuoi:

```
claude plugin update otto@ltvbeat
```
