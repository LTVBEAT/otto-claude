---
name: prepara-creativita
description: Usala quando qualcuno chiede di preparare un cliente LTV/Beat per le creatività, di fare, completare o aggiornare la sua scheda creativa, o di renderlo pronto per il plugin creatività - «prepara <cliente> per le creatività», «fai la scheda creativa di <cliente>», «aggiorna la scheda creativa di <cliente>», «riprendi la scheda creativa di <cliente>», anche quando Otto su Slack ha già fatto la bozza e dice di riprenderla in locale. NON per creare un'ad (quella è clienti-beat) né per scrivere copy (copywriter).
---

# prepara-creativita

La procedura sta nella wiki di Otto, in `agency/scheda-creativa/prepara-creativita.md`: leggila tutta con
`leggi_dalla_knowledge` del plugin `otto` e seguila passo per passo. Il modello dei file da scrivere è nella stessa
cartella; il metodo che vale per tutti i clienti in `agency/metodo-creativo/metodo-creativo.md`.

Qui sei **in locale**: fai tutto, compreso quello che da Slack non si può fare.

- **Brand kit su Figma:** `bash "${CLAUDE_PLUGIN_ROOT}/scripts/figma.sh"` (struttura, schermate, immagini), come in
  `clienti-beat`. Le schermate si guardano, non basta il testo.
- **Feedback della persona:** `bash "${CLAUDE_PLUGIN_ROOT}/scripts/feedback.sh" mostra`. Non li copi: li proponi.
- **Scritture nella wiki:** con `scrivi_nella_knowledge` e `modifica_nella_knowledge` del plugin `otto`. Vanno subito
  su GitHub a nome della persona: prima di scrivere mostrale l'elenco dei file e cosa cambia, e chiedi l'ok una volta
  per tutto il pacchetto.
- **Se Otto ha già fatto la bozza da Slack:** riparti da lì (procedura, passo 2), senza rifare la parte di testo.
- **Giro di prova:** con la skill `clienti-beat`, su un brief vero del cliente e su una statica di un altro brand. I
  crediti Higgsfield si dicono prima.
