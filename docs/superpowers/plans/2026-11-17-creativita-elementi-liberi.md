# Rudolf: elementi dell'ad liberi - piano

> **Per chi esegue:** una sezione alla volta, con l'ok di Max fra una e l'altra (regola di Max). Passi con le
> caselle `- [ ]`.

**Obiettivo:** Rudolf sceglie per ogni ad quali elementi usare (logo, headline, subheadline, copy, CTA, prove):
tutti, alcuni o nessuno, e lo motiva.

**Come:** cambiano solo testi di istruzioni (due subagenti, la skill `clienti-beat`, la scheda modello). Il «test»
è un confronto: gli stessi input fatti girare con le istruzioni di `origin/main` e con quelle nuove.

**Disegno:** `docs/superpowers/specs/2026-11-17-creativita-elementi-liberi-design.md`

**Ramo:** `creativita/elementi-liberi`, copia in `worktrees/creativita-elementi`.

## Vincoli

- Si toccano solo i file elencati. Scene, modello Higgsfield, mockup e `feedback.md` restano come sono.
- Niente Higgsfield e niente Figma fino alla Sezione 6, e lì solo con l'ok di Max.
- La knowledge di Otto si scrive solo con l'ok di Max (va su GitHub a suo nome).
- Italiano asciutto, niente trattino lungo `—` nei testi nuovi.

## Cosa può andare storto (da guardare nei test)

1. Rudolf sceglie «tutti» in ogni variante perché è la scelta sicura → il confronto della Sezione 4 lo misura.
2. «Nessuno» su un visual che da solo non si capisce → nel confronto ogni «nessuno» deve avere un visual che parla.
3. Brief con la CTA già scritta: la CTA del brief resta anche se la scelta direbbe di toglierla.
4. `visual-testi` gira in parallelo e non sa la scelta: scrive per tutti, il passo 4 scarta. Controllare che la skill
   dica di scartare.
5. Scheda di un cliente non aggiornata (dice ancora «Elementi fissi»): la skill deve leggerla come «elementi
   disponibili», non come obbligo.

---

## Sezione 1 - Prova di partenza (istruzioni di oggi)

- [ ] **1.1** Chiedere a Max due statiche di riferimento: una con una frase sola, una senza CTA (incollate in chat).
  Cliente: Learnn, materiale scelto dalla wiki.
- [ ] **1.2** Preparare in `<scratchpad>/test-elementi/` il pacchetto d'ingresso uguale per tutti i giri:
  `ingresso.md` con la scheda `clienti/learnn/creativita.md`, le regole copy da `brand.md` (Lessico, Do, Don't),
  l'uscita di `feedback.sh mostra`, numero varianti 3.
- [ ] **1.3** Esportare le istruzioni di oggi: `git show origin/main:plugins/creativita/agents/<agente>.md` in
  `<scratchpad>/test-elementi/vecchi/`.
- [ ] **1.4** Per ogni statica lanciare insieme due subagenti `general-purpose` (modello sonnet), ognuno con: «segui
  le istruzioni in `vecchi/<agente>.md`», la statica, `ingresso.md`. Uscite in `vecchi/<statica>-<agente>.md`.
- [ ] **1.5** Tabella `confronto.md`: per statica e variante, quali elementi finirebbero sull'ad e perché.

## Sezione 2 - I due subagenti

**File:** `plugins/creativita/agents/format-concept.md`, `plugins/creativita/agents/visual-testi.md`

- [ ] **2.1** `format-concept`, «Cosa restituisci»:
  - punto 1 Format: aggiungere quali elementi di testo ha la reference e quanto pesa il visual;
  - punto 3, per ogni riadattamento, nuova voce **«Elementi:»** con la combinazione fra logo, headline,
    subheadline, copy, CTA, prove (anche «nessuno») e una riga sul perché;
  - la voce sulla scena: spazi vuoti solo per gli elementi scelti, nessuno spazio con «nessuno».
- [ ] **2.2** `format-concept`, «Regole», tre righe nuove: nessun elemento è obbligatorio; criterio (il visual dice
  già il messaggio → meno elementi; il visual da solo non si capisce o serve l'offerta → di più; la reference è un
  indizio); le varianti non hanno tutte la stessa combinazione, salvo brief.
- [ ] **2.3** `visual-testi`: «Testi della statica» elenca anche quelli che mancano; i testi riscritti diventano
  «per ogni elemento possibile (headline, subheadline, copy, CTA), il passo successivo tiene solo quelli scelti»;
  via «Lunghezza simile a quella della statica», resta «brevi».
- [ ] **2.4** Controllo: `grep -n "headline, testi, CTA e logo\|headline, testi brevi, CTA" plugins/creativita/agents/`
  non trova niente.
- [ ] **2.5** Commit `feat(creativita): i subagenti scelgono gli elementi dell'ad`.

## Sezione 3 - Skill e scheda modello

**File:** `plugins/creativita/skills/clienti-beat/SKILL.md`, `plugins/creativita/scheda-modello.md`,
`plugins/creativita/.claude-plugin/plugin.json`

- [ ] **3.1** SKILL passo 4: ogni variante ha la voce **«Elementi»** presa da `format-concept`; la voce «Copy» diventa
  «solo per gli elementi scelti», scartando i testi di `visual-testi` che non servono.
- [ ] **3.2** SKILL passo 2 e passo 6: «elementi fissi dell'ad» → «elementi dell'ad»; si montano solo quelli scelti;
  le regole della scheda (forma, colori, ripiego) valgono quando ci sono; con tutti, l'impaginazione della scheda,
  se manca quella di oggi (logo in alto, testi nello spazio libero, CTA e prove in basso, nella safe zone). Una scheda
  che dice ancora «fissi» si legge come elenco di elementi disponibili.
- [ ] **3.3** SKILL passo 7: nel resoconto, per ogni ad, combinazione e perché.
- [ ] **3.4** SKILL «Ingresso dal brief», ad con i testi a metà: i testi del brief restano tutti; i pezzi mancanti
  solo se la scelta li prevede.
- [ ] **3.5** `scheda-modello.md`: «Elementi fissi dell'ad» → «Elementi dell'ad», riga nuova «Impaginazione con tutti
  gli elementi: <frame del brand kit o descrizione>»; «Quando non ci stanno» resta.
- [ ] **3.6** `plugin.json` versione `0.2.11`.
- [ ] **3.7** Controllo: `grep -rn "lementi fissi" plugins/creativita/` non trova niente; `bash
  plugins/creativita/scripts/*.test.sh` passano come prima.
- [ ] **3.8** Commit `feat(creativita): la skill monta solo gli elementi scelti (0.2.11)`.

## Sezione 4 - Prova con le istruzioni nuove

- [ ] **4.1** Ripetere 1.4 con le istruzioni del ramo (`plugins/creativita/agents/`), stesso `ingresso.md`, stesse
  statiche. Uscite in `nuovi/`.
- [ ] **4.2** Completare `confronto.md` e mostrarlo a Max. Passa se: le nuove non mettono sempre tutto; le tre
  varianti di una statica non hanno la stessa combinazione; ogni «nessuno» o combinazione corta ha un perché che
  regge guardando la scena. Se non passa, si torna alla Sezione 2 con quello che il confronto ha mostrato.

## Sezione 5 - Knowledge di Otto (solo con l'ok di Max)

- [ ] **5.1** `agency/scheda-creativa/creativita.md`: «Elementi fissi dell'ad» → «Elementi dell'ad», riga
  dell'impaginazione con tutti gli elementi.
- [ ] **5.2** `clienti/learnn/creativita.md`: stessa rinomina; «Non togliere Trustpilot per fare spazio» → «Quando c'è
  la CTA, Trustpilot le sta accanto: prima si stringe, poi la card».
- [ ] **5.3** Dire a Max cosa è stato scritto. Enaroba, Qura e SFX restano per dopo.

## Sezione 6 - Chiusura

- [ ] **6.1** Con l'ok di Max: un giro completo di Rudolf su Learnn (Higgsfield + Figma) con una delle due statiche.
- [ ] **6.2** Push del ramo e PR verso `main` su `LTVBEAT/otto-claude`; il merge lo fa Max.
