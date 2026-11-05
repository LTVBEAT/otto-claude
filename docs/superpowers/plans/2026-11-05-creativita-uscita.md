# Plugin creativita - piano per l'uscita al team

> **Per chi esegue:** skill obbligatoria superpowers:executing-plans o superpowers:subagent-driven-development.
> **Una sezione alla volta:** finita una sezione ci si ferma, si dice a Max cosa è fatto e cosa è verificato, e si passa
> alla successiva solo con il suo ok. I passi usano le caselle `- [ ]`.

**Obiettivo:** una persona del team installa il plugin, si collega, porta una statica o un brief di Learnn fino alle ad
su Figma senza chiedere niente a Max, e il plugin ricorda i suoi feedback anche dopo gli aggiornamenti.

**Architettura:** si lavora sul plugin che c'è (`plugins/creativita/`, ramo `feat/creativita`). Uno script nuovo per i
feedback personali, la skill riscritta in quattro punti (feedback, correzioni in chat, scheda del cliente, brief), i
commenti di Figma tolti da skill e script, la scheda di Learnn scritta nella wiki, poi versione, README e prova del team.

**Tecnica:** bash con jq negli script (gli hook restano senza jq), test `*.test.sh` con programmi finti nel PATH, skill
in Markdown, strumenti della knowledge del plugin Otto per leggere e scrivere la wiki.

**Spec:** `docs/superpowers/specs/2026-11-05-creativita-design.md` (e, dove non dice altro, `2026-11-03-creativita-design.md`).
Glossario: `plugins/creativita/CONTEXT.md`.

## Vincoli globali

- Otto non fa niente: solo `elenca_knowledge`, `cerca_nella_knowledge`, `leggi_dalla_knowledge` e, per la scheda,
  `scrivi_nella_knowledge` con la conferma della persona. Mai `chiedi_a_otto`.
- Il repo è leggibile da chiunque: nessuna password, token o indirizzo di webhook in nessun file.
- Nessun invio automatico dei feedback. Il `feedback.md` del plugin si cambia solo a mano.
- Nessuna regola di un cliente nella skill o negli script: stanno nella scheda `clienti/<cliente>/creativita.md`.
- Testi in italiano, con `-` e mai il trattino lungo.
- Commit solo con l'ok di Max a fine sezione; push, PR e merge su main li lancia Max.
- Dopo ogni modifica al codice senza commit: `GRAPHIFY_BACKEND=none graphify update .` dalla radice del repo.

## Review Focus

1. Feedback personale con il plugin aggiornato: il file non sta nella cartella del plugin e c'è ancora dopo
   (test `feedback percorso fuori dal plugin`, Sezione 2).
2. Feedback dato due volte per lo stesso cliente: una sola intestazione del cliente, non due (test `stesso cliente`, Sezione 2).
3. Correzione su «C2» quando nel lotto ci sono anche `C2-2` e `C2-3`: si tocca solo `C2`, nei due formati (regola
   scritta nella skill, controllata a mano nel collaudo, Sezione 7).
4. Cliente senza scheda o senza brand kit: il giro si ferma e dice cosa manca, non va avanti a metà (Sezione 4,
   controllato a mano con un cliente finto nel collaudo).
5. Brief da Google Doc con immagini: Claude chiede di incollarle, non prova Composio (Sezione 5, `grep` sulla skill).

---

### Sezione 1: Mettere al sicuro il giro B15 - fatta il 05/11

Le correzioni del 05/11 sono fatte e verificate ma non committate (vedi Sezione 7 del piano del 03/11).

- [x] **Passo 1:** dalla radice del repo lancia le quattro suite.
  Run: `for t in plugins/creativita/hooks/comandi-creativita.test.sh plugins/creativita/scripts/{controlla,figma,scene}.test.sh; do bash "$t" || echo "FALLITA $t"; done`
  Expected: quattro `ok`, nessun `FALLITA`.
- [x] **Passo 2:** `claude plugin validate plugins/creativita` → nessun errore.
- [x] **Passo 3:** in testa al piano del 03/11 una riga: «Le sezioni 3-6 sono sostituite dal piano del 05/11
  (`2026-11-05-creativita-uscita.md`)».
- [x] **Passo 4:** commit, con l'ok di Max.
  ```bash
  git add plugins/creativita docs/superpowers
  git commit -m "fix(creativita): correzioni dal giro B15, glossario e spec del 05/11"
  ```

---

### Sezione 2: I feedback in due memorie - fatta il 05/11

**Files:**
- Create: `plugins/creativita/scripts/feedback.sh`, `plugins/creativita/scripts/feedback.test.sh`
- Modify: `plugins/creativita/skills/creativita/SKILL.md` (sezione «Il feedback», passi 2 e 3), `plugins/creativita/feedback.md` (testa)

**Interfaces:**
- Produces: `feedback.sh percorso` stampa il percorso del file personale e lo crea se manca. `feedback.sh mostra`
  stampa prima `## Feedback del team` con il `feedback.md` del plugin, poi `## I tuoi feedback` con il file personale
  (o `Nessuno.`). `feedback.sh aggiungi <tutti|Cliente> <testo>` aggiunge `- <testo>` sotto `## Per tutti i clienti`
  o sotto `### <Cliente>` dentro `## Per cliente`, crea le intestazioni che mancano e stampa `✅ Salvato: <testo>`.
  Uscite: 0 ok, 2 uso sbagliato.
- Cartella: `${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/creativita-ltvbeat}` (la stessa dell'hook), file
  `feedback-personale.md`. Il file del team è `$(dirname "$0")/../feedback.md`.

- [x] **Passo 1: test che falliscono** in `feedback.test.sh`, sullo stile di `scene.test.sh` (`HOME` e
  `CLAUDE_PLUGIN_DATA` in una cartella temporanea):
  - `feedback percorso fuori dal plugin`: il percorso stampato comincia con la cartella dati e non con `plugins/creativita`.
  - `percorso senza CLAUDE_PLUGIN_DATA`: con la variabile vuota il file è in `$HOME/.claude/plugins/data/creativita-ltvbeat/`.
  - `aggiungi tutti`: il file contiene `## Per tutti i clienti` e la riga `- mai testo sopra la foto`.
  - `stesso cliente`: due `aggiungi Learnn` → una sola riga `### Learnn`, due righe sotto.
  - `mostra`: `## Feedback del team` viene prima di `## I tuoi feedback`, e ci sono tutte e due le righe aggiunte.
  - `mostra senza file personale`: sotto `## I tuoi feedback` c'è `Nessuno.`
  - `uso sbagliato`: `feedback.sh boh` e `feedback.sh aggiungi tutti` (senza testo) escono con 2.
- [x] **Passo 2:** `bash plugins/creativita/scripts/feedback.test.sh` → FAIL, lo script non esiste.
- [x] **Passo 3:** scrivi `feedback.sh` (testa d'uso nelle righe 2-9 come gli altri script, `uso()` uguale).
- [x] **Passo 4:** di nuovo il test → `ok`.
- [x] **Passo 5: la skill.** Riscrivi «Il feedback» così:
  - al passo 2 si lancia `feedback.sh mostra` e si segue; l'uscita intera va ai subagenti del passo 3;
  - vincono su brand kit, wiki e reference; tra i due, per la persona vince il suo, e il resoconto lo dice;
  - quando la persona dà un'indicazione e non è chiaro se vale solo lì o sempre, chiedi in una riga «Vale solo qui o
    sempre?»; se vale sempre, `feedback.sh aggiungi` e una riga su cosa hai salvato;
  - se contraddice una riga vecchia del file personale, togli la vecchia con Edit sul file di `feedback.sh percorso`;
  - non si scrive mai nel `feedback.md` del plugin; «quali indicazioni hai?» → `feedback.sh mostra`.
  Nella testa di `feedback.md` del plugin: «Si cambia solo a mano, quando Max sceglie un feedback per tutti: Claude non
  ci scrive».
- [x] **Passo 6:** `grep -n 'Il file resta solo se finisce nel repo' plugins/creativita/skills/creativita/SKILL.md` → niente.
- [x] **Passo 7:** commit, con l'ok di Max: `feat(creativita): feedback personali fuori dal plugin`.

---

### Sezione 3: Correzioni in chat, via i commenti di Figma - fatta il 05/11

**Files:**
- Modify: `plugins/creativita/scripts/figma.sh` (righe 2-9 e 156-201, `ISTRUZIONI`), `plugins/creativita/scripts/figma.test.sh` (rotta e fixture dei commenti, test righe 233-255)
- Modify: `plugins/creativita/skills/creativita/SKILL.md` (descrizione, tabella delle letture, «Il giro delle correzioni»)

- [x] **Passo 1: test che fallisce** in `figma.test.sh`: `figma commenti LRhz 53:671` esce con 2 (comando che non esiste
  più). Togli i test, la rotta e le fixture di `commenti`, `rispondi` e `reazione`.
- [x] **Passo 2:** `bash plugins/creativita/scripts/figma.test.sh` → FAIL su `commenti` (oggi esce con 0).
- [x] **Passo 3:** togli da `figma.sh` i tre comandi e le loro righe d'uso; in `ISTRUZIONI` i permessi del token
  diventano «File content Read, Current user Read».
- [x] **Passo 4:** di nuovo il test → `ok`.
- [x] **Passo 5: la skill.** Togli «Il giro delle correzioni», la riga dei commenti nella tabella e i commenti dalla
  descrizione. Al loro posto «Le correzioni in chat»:
  - la persona nomina l'ad (`C2`, `C2-2`, «la 1:1 della C3»); se il nome non basta a capire quale, chiedilo;
  - `C2` senza formato vuol dire i due frame di `C2` (9:16 e 1:1), mai `C2-2` o `C2-3` né le altre ad del lotto;
  - testi, colori, posizioni e logo con `use_figma` sui frame indicati; se la correzione riguarda la scena, nuovo
    prompt e `scene.sh genera <cartella> <nome>`, con il costo detto prima;
  - se non è chiaro se vale solo lì o sempre, la domanda della Sezione 2;
  - chiusura: frame toccati con link e crediti usati.
  Nella descrizione: «quando la persona chiede di correggere un'ad già fatta».
- [x] **Passo 6:** `grep -n -i 'commenti\|rispondi\|reazione' plugins/creativita/skills/creativita/SKILL.md plugins/creativita/scripts/figma.sh` → niente.
- [x] **Passo 7:** commit, con l'ok di Max: `feat(creativita): correzioni in chat, via i commenti di Figma`.

---

### Sezione 4: La scheda del cliente come punto d'ingresso - fatta il 05/11

**Files:**
- Create: `plugins/creativita/scheda-modello.md`
- Modify: `plugins/creativita/skills/creativita/SKILL.md` (passi 1, 2, 4, 6)

**Interfaces:**
- Produces: i campi della scheda, che la Sezione 5 riempie per Learnn: **File Figma** (link e nome della pagina del
  brand kit), **Materiali** (dove sono, nella wiki e su Figma), **Linee guida**, **Copy** (regole e tono), **Skill del
  cliente** (file da seguire e quando), **Elementi fissi dell'ad** (CTA lunga e corta, prove come Trustpilot con la
  versione piccola, componente del logo, colore della card di ripiego, safe zone se diversa da quella di Meta),
  **Quando non ci stanno**.

- [x] **Passo 1:** scrivi `scheda-modello.md` con i campi qui sopra, ognuno con una riga che dice cosa ci va. È il
  modello per i clienti nuovi.
- [x] **Passo 2: passo 2 della skill.** Si comincia da `leggi_dalla_knowledge clienti/<slug>/creativita.md`. Se manca
  la scheda, se manca il link Figma o se nel file non c'è la pagina del brand kit, il giro si ferma: «<Cliente> non è
  ancora pronto per il plugin: manca <cosa>. Il modello della scheda è in scheda-modello.md del plugin». Togli la
  ricerca di `figma.com/design` nella cartella e la richiesta del link.
- [x] **Passo 3: regole di Learnn fuori.** Nei passi 4 e 6 CTA, Trustpilot, logo, card e safe zone si leggono da
  «Elementi fissi dell'ad» della scheda; resta la regola generale (dove vanno, il ripiego in tre passi). Gli esempi
  «per Learnn» diventano generici.
- [x] **Passo 4:** `grep -c -i 'learnn\|trustpilot\|antracite' plugins/creativita/skills/creativita/SKILL.md` → `0`.
- [x] **Passo 5:** commit, con l'ok di Max: `feat(creativita): la scheda del cliente come punto d'ingresso`.

---

### Sezione 5: Brief come si vuole, Higgsfield con la password condivisa - fatta il 05/11

**Files:**
- Modify: `plugins/creativita/skills/creativita/SKILL.md` («Ingresso dal brief»)
- Modify: `plugins/creativita/scripts/controlla.sh` (`righe_higgsfield`, `account`), `plugins/creativita/scripts/controlla.test.sh`
- Modify: `plugins/creativita/hooks/comandi-creativita.sh` (testo di `account`)
- Modify: `docs/superpowers/specs/2026-11-03-creativita-design.md` («Scelte mie»: `chiedi_a_otto` tolta il 05/11)

- [x] **Passo 1: test che fallisce** in `controlla.test.sh`: senza login la riga di Higgsfield contiene
  «email e password dell'account dell'agenzia: chiedile a Max».
- [x] **Passo 2:** `bash plugins/creativita/scripts/controlla.test.sh` → FAIL su quel testo.
- [x] **Passo 3:** cambia il testo in `righe_higgsfield` e nel ramo `account` di `controlla.sh`; nell'hook, il testo
  di `/creativita account` dice lo stesso.
- [x] **Passo 4:** `controlla.test.sh` e `comandi-creativita.test.sh` → `ok`.
- [x] **Passo 5: la skill.** «Ingresso dal brief»: il brief arriva come la persona preferisce (testo in chat, immagini
  incollate, link al Doc). Dal Doc il testo si legge con il connettore Google Drive della persona; le immagini dentro
  il Doc non arrivano: chiedi di incollarle in chat, e il file sta nella riga `[Image: source: <percorso>]` come per
  la statica. Togli Composio e l'account di Max.
- [x] **Passo 6:** `grep -n -i 'composio\|massimo.cardini' plugins/creativita/skills/creativita/SKILL.md` → niente.
- [x] **Passo 7:** commit, con l'ok di Max: `feat(creativita): brief senza Composio, password Higgsfield da Max`.

---

### Sezione 6: La scheda di Learnn nella wiki

Si scrive nella wiki, non nel repo: nessun commit.

- [ ] **Passo 1:** leggi `clienti/learnn/brand.md`, `creativita-repo-learnn.md`, `scheda.md`, `safe-zone-creative-video.md`
  e le regole di Learnn tolte dalla skill nella Sezione 4 (`git show` del commit). Il file Figma è
  `LRhzTaDLREM1sSKAJKGoMV` («Creatività Adv - Learnn»), brand kit nella pagina `3:2`.
- [ ] **Passo 2:** scrivi la scheda sul modello di `scheda-modello.md` e mostrala a Max in chat.
- [ ] **Passo 3:** con il suo ok, `scrivi_nella_knowledge` su `clienti/learnn/creativita.md` (la conferma la dà lui
  nella finestra).
- [ ] **Passo 4:** `leggi_dalla_knowledge clienti/learnn/creativita.md` → c'è, con il link Figma; `bash
  plugins/creativita/scripts/figma.sh struttura LRhzTaDLREM1sSKAJKGoMV "" 1` → c'è la pagina «Brand kit».

---

### Sezione 7: Uscita al team

**Files:**
- Modify: `plugins/creativita/.claude-plugin/plugin.json` (`version` 0.1.0 → 0.2.0), `README.md` (sezione creativita)

- [x] **Passo 1:** versione 0.2.0; nel README una sezione corta: come si installa (`installa.sh ... | bash -s creativita`),
  `/creativita configura`, password di Higgsfield da chiedere a Max, come si dà un brief, correzioni e feedback in chat.
- [x] **Passo 2:** tutte le suite (`comandi-creativita`, `controlla`, `figma`, `scene`, `feedback`) → cinque `ok`;
  `claude plugin validate plugins/creativita` → nessun errore.
- [x] **Passo 3:** revisione finale di tutto il ramo da un revisore nuovo, sul modello più capace; si sistemano
  Critical e Important.
- [ ] **Passo 4:** commit, con l'ok di Max: `feat(creativita): versione 0.2.0 per il team`. Push e PR li lancia Max,
  poi il merge su main: da lì l'aggiornamento automatico arriva a tutti.
- [ ] **Passo 5: collaudo** con Sofia o Elisa sul loro computer: installazione, `/creativita configura` (posto Full in
  Beat Performance compreso), un brief di Learnn fino a Figma, una correzione su `C2` con `C2-2` nel lotto, un
  feedback, un aggiornamento del plugin e il feedback ancora lì. Quello che si rompe diventa una task.
- [ ] **Passo 6:** aggiorna `task.md` della cartella principale del repo.
