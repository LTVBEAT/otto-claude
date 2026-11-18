# Rudolf: elementi dell'ad liberi - disegno

17/11/2026 · approvato da Max: -

## Perché

Le statiche di Rudolf (plugin `creativita`) escono tutte con la stessa ossatura: headline, sottotitolo, CTA, prove,
logo. Lo schema viene dal giro di Learnn preso come modello ed è scritto in cinque posti: i due subagenti, la skill
`clienti-beat` (passi 4 e 6), la scheda di Learnn e la scheda modello dell'agenzia, il metodo immagini. Il risultato è
poca creatività e lotti che sembrano la stessa ad.

## Cosa vuole Max

- **Niente è obbligatorio.** Logo, headline, subheadline, copy, CTA (e le prove accanto alla CTA) sono strumenti.
  Rudolf sa quali sono e come si dispongono quando ci sono tutti.
- Per ogni ad sceglie quali servono: tutti, alcuni o nessuno. Più il visual è impattante, meno ne servono. Nessuno è
  raro ma possibile.
- Deve imparare a capire quando un elemento serve e quando no.

Non obiettivi: non si tocca la generazione delle scene, il modello di immagine, il montaggio dei mockup.
Anti obiettivo: un nuovo schema fisso (un catalogo di impianti a rotazione). Scartato per questo.

## Approcci

- **A. Scelta motivata (scelto da Max).** `format-concept` decide per ogni variante quali elementi usare e lo motiva
  in una riga; `visual-testi` scrive solo quelli; il montaggio mette solo quelli.
- B. Solo istruzioni più morbide (togliere gli elenchi fissi). Più piccolo, ma il modello tende a tornare alla scelta
  sicura «tutti». Scartato.
- C. Catalogo di impianti a rotazione. È un nuovo schema fisso. Scartato.

## Il disegno

1. **`format-concept`**: nel format della reference legge anche quali elementi di testo ha e quanto pesa il visual.
   Per ogni riadattamento aggiunge **«Elementi:»** con la combinazione scelta (anche «nessuno») e una riga sul perché.
   La scena lascia spazi vuoti solo per gli elementi scelti; con «nessuno» non lascia spazi.
   Criterio, scritto nell'agente: il visual dice già il messaggio → meno elementi; il visual da solo non si capisce o
   serve l'offerta → più elementi. La reference è un indizio, non un obbligo.
2. **Le varianti di uno stesso giro non hanno tutte la stessa combinazione**, salvo che il brief la imponga.
3. **`visual-testi`**: scrive solo i testi degli elementi scelti. Se la combinazione non è ancora decisa (gira in
   parallelo), propone i testi per tutti gli elementi possibili e il passo 4 tiene solo quelli scelti.
4. **Skill `clienti-beat`**:
   - passo 4: ogni variante ha la riga «Elementi», presa da `format-concept`; i copy solo per quelli;
   - passo 6: «elementi fissi dell'ad» diventa «elementi dell'ad»: si montano solo quelli scelti, con le regole della
     scheda (forma, colori, ripiego quando non ci stanno) che valgono quando ci sono;
   - passo 7: nel resoconto, per ogni ad, la combinazione e il perché;
   - ingresso dal brief: i testi del brief restano come sono; i pezzi mancanti si aggiungono solo se la scelta li
     prevede, non per completare lo schema.
5. **Scheda modello del plugin** (`scheda-modello.md`): «Elementi fissi dell'ad» → «Elementi dell'ad», con una riga
   nuova «Impaginazione con tutti gli elementi: <frame del brand kit o descrizione>».
6. **Knowledge di Otto** (va su GitHub a nome di Max, solo con il suo ok): stessa rinomina nella scheda modello
   `agency/scheda-creativa/creativita.md` e in `clienti/learnn/creativita.md`, dove «Non togliere Trustpilot per fare
   spazio» diventa «quando c'è la CTA, Trustpilot le sta accanto: prima si stringe, poi la card».
   Le altre schede (enaroba, qura, sfx) si allineano dopo i test.
7. Versione del plugin 0.2.11.

## Scelte di Claude (da controllare)

- **Le prove** (Trustpilot) sono un elemento a sé, di solito accanto alla CTA: Max non le ha nominate.
- **Impaginazione con tutti gli elementi**: se la scheda non la dice, vale quella di oggi della skill (logo in alto,
  testi nello spazio libero, CTA e prove in basso, dentro la safe zone).
- Il feedback del team «Se il messaggio sta già nel visual, niente headline né copy in overlay» resta com'è: è
  coerente. `feedback.md` lo cambia solo Max.
- Il metodo immagini (`agency/metodo-creativo/metodo-immagini.md`) non si tocca: non impone elementi.

## Test

Prima di Higgsfield e Figma: due statiche di riferimento (una a frase sola, una senza CTA) e un cliente pronto
(Learnn). Si fanno girare i due subagenti con le istruzioni di oggi e con quelle nuove, 3 varianti ciascuno, e si
confrontano le combinazioni scelte. Passa se le nuove non mettono sempre tutto, variano fra le varianti e il perché
regge. Poi, con l'ok di Max, un giro completo su Figma.
