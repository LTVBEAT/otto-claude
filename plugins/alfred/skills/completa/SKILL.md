---
name: completa
description: Avvisa Alfred che un lavoro o una sotto-chat su una task di un cliente LTV è finita. Usala con /alfred:completa o quando l'utente dice «ho finito», «la sotto-chat è chiusa», «fatto» su un lavoro di un cliente.
---

# Chiudere un lavoro con Alfred

Alfred non vede le chat: va avvisato. Prima di scrivergli raccogli dall'utente, se non li ha già detti:
- cliente e task (o il numero della sotto-chat proposta dal recap);
- cosa è stato fatto, in una o due righe;
- la prova: un link, un dato o la conferma di una persona. Senza prova Alfred non chiude niente.

Poi `chiedi_a_alfred`: «Sotto-chat <numero> chiusa» oppure «Ho fatto: <cosa>, cliente <...>, task <...>,
prova <...>». Alfred segna la chiusura e propone come aggiornare TaskFlow: riporta la proposta **tale e
quale** e aspetta l'ok dell'utente.
