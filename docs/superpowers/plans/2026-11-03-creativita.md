# Plugin creativita - piano di lavoro

> **Per chi esegue:** skill obbligatoria superpowers:subagent-driven-development (consigliata) o
> superpowers:executing-plans; per hook e fascia anche la skill `plugin-authoring`. **Una sezione alla volta:** finita
> una sezione ci si ferma, si dice a Max cosa è fatto e cosa è verificato, e si passa alla successiva solo con il suo ok.
> I passi usano le caselle `- [ ]`.

**Obiettivo:** installato il plugin creativita e fatta la configurazione guidata, una persona del team arriva da «riadattami
questa statica per X» a frame Figma ritoccabili nel brand del cliente, con una fascia che mostra modalità e fase.

**Architettura:** un plugin nuovo, `creativita`, nel marketplace del team `LTVBEAT/otto-claude`, nessun server nuovo e
nessun legame con Otto per chi lo usa (Max, 03/11). Un hook gestisce i comandi `/creativita`, una mod disegna la fascia.
Le skill del giro e del brand kit leggono la wiki con gli strumenti di lettura della knowledge (oggi nel plugin Otto,
che resta installato), Figma dal suo MCP ufficiale e Higgsfield dalla sua CLI.

**Tecnica:** bash (hook, senza jq), mod TSX di Claude Code con i test `claude-code/testing`, skill e subagenti del
plugin, MCP ufficiale di Figma, CLI `@higgsfield/cli`.

**Disegno:** `docs/superpowers/specs/2026-11-03-creativita-design.md`

## Vincoli globali

- Una modalità alla volta: accendere la creazione spegne la modalità Otto; se Otto si riaccende dopo, la creazione si spegne.
- Formati: **9:16 = 1080×1920** e **1:1 = 1080×1080**. Niente 4:5.
- Scena: GPT Image 2, 1k, qualità **media** di default, senza testo, statica come reference.
- Tetti: **6 crediti per proposta**, **18 per giro**, costo mostrato e ok prima di ogni spesa, nessun nuovo tentativo
  automatico.
- Prove solo da materiale vero del cliente; regole e istruzioni del cliente lette dalla wiki di Otto a ogni giro, mai
  copiate nelle skill.
- File Figma nel progetto condiviso «Giotto» del team Beat Performance, nome `Giotto - <Cliente>`.
- Hook solo con bash, sed e grep. Testi in italiano, nei documenti `-` e mai il trattino lungo.
- Commit su ok di Max; push, PR e unione su main le lancia Max.

## Review Focus

- **Modalità Otto accesa e `/creativita on`:** la modalità Otto si spegne e i messaggi non vanno più a Otto; se Otto
  si riaccende dopo, vince Otto. Test in Sezione 1.
- **Configurazione con un passo a metà** (CLI Higgsfield installata ma login non fatto, Figma senza accesso al
  progetto): il controllo dice il passo esatto che manca, non «errore». Test in Sezione 2.
- **Giro che supererebbe 18 crediti o 6 su una proposta:** la skill si ferma prima di lanciare la CLI e dice i crediti
  rimasti. Verifica in Sezione 3.
- **Cliente senza istruzioni o brand nella wiki:** la skill lo dice e non inventa un brand. Verifica in Sezione 3.
- **Font del cliente assente in Figma:** la skill lo dice e usa il fallback scritto nel brand kit. Verifica in Sezione 5.

---

### Sezione 1: Plugin creativita, comandi e fascia - fatta il 03/11

**File:** `plugins/creativita/` (`.claude-plugin/plugin.json`, `hooks/hooks.json`, `hooks/comandi-creativita.sh`,
`hooks/fascia-creativita.tsx`, `types/index.d.ts`, test `hooks/comandi-creativita.test.sh` e
`hooks/fascia-creativita.test.tsx`), voce `creativita` in `.claude-plugin/marketplace.json`.

**Interfacce:**
- Produce: il file della sessione `~/.claude/plugins/data/creativita-ltvbeat/modalita/<sessione>` con la fase
  (`analisi`, `proposte`, `scena`, `figma`); niente file = creazione spenta. A creazione accesa l'hook passa a Claude,
  a ogni messaggio, il percorso esatto del file e il comando `printf '<fase>\n' > '<file>'` per cambiare fase.
- Fascia: «Creazione creatività - <fase>», con `· /creativita off per uscire · /creativita help`.

- [x] Test che falliscono, poi comandi `/creativita on`, `off`, `help` e fascia; la fase si rilegge anche dopo ogni
  strumento.
- [x] `bash plugins/creativita/hooks/comandi-creativita.test.sh` → ok; `claude plugin test plugins/creativita` → 6 su 6;
  `claude plugin validate` del plugin e del marketplace → passati; test di Otto e Mulan invariati e verdi.
- [ ] Prova a vista in una sessione nel terminale con `claude --plugin-dir <copia>/plugins/creativita`.
- [x] Commit `feat(creativita): plugin con comandi e fascia della creazione`.

### Sezione 2: Configurazione guidata e cambio di account - fatta il 03/11

**File:** `plugins/creativita/scripts/controlla.sh` (controlli sul computer) e il suo test `controlla.test.sh`;
comandi `configura` e `account` in `hooks/comandi-creativita.sh`; caso `creativita` in `installa.sh` e `installa.ps1`
(nessun passo del token). Niente skill a parte: le istruzioni le passa l'hook, come per `/otto doctor`.

**Interfacce:**
- `controlla.sh configura`: righe ✅/❌ per plugin Otto (wiki), Figma (`claude mcp list`, server `mcp.figma.com`),
  CLI Higgsfield e login (`higgsfield workspace list`), ognuna con l'unica azione da fare. Ogni comando ha un tempo
  massimo di 10 secondi. Il token di Higgsfield non si chiede mai alla CLI.
- Poi Claude, con gli strumenti: `elenca_knowledge` per la wiki e `whoami` di Figma, che deve dare un posto **Full nel
  piano «Beat Performance»**.
- `controlla.sh account`: `higgsfield account status` e `workspace status`. Login, logout e cambio di workspace li fa la
  persona nel terminale.

- [x] Test che falliscono, poi script, comandi e installazione; test bash verdi, plugin e catalogo validati, sintassi
  PowerShell controllata.
- [x] Prova vera sul Mac di Max: wiki ✅, Figma ✅ (Full in Beat Performance), CLI Higgsfield ✅, login Higgsfield ❌.
- [x] Commit `feat(creativita): configurazione guidata e account Higgsfield`.

### Sezione 3: Il giro fino alla scena

**File:**
- Crea: `plugins/creativita/skills/creativita/SKILL.md`, `plugins/creativita/agents/format-concept.md`,
  `plugins/creativita/agents/visual-testi.md`

**Interfacce:**
- Consuma: `cerca_nella_knowledge`, `leggi_dalla_knowledge`, `elenca_knowledge` (cliente, brand, istruzioni, skill del
  cliente); la CLI Higgsfield; la fase della Sezione 1.
- Produce:
  - `format-concept`: da statica e cliente, che format è, com'è costruito, cosa vuole dire, perché funziona, e fino a 3
    modi di riadattarlo senza rifarlo uguale.
  - `visual-testi`: palette, composizione, elementi, gerarchia e tono dei testi, e come rifarli sul brand del cliente,
    colori della scena compresi.
  - Skill `creativita`: chiede il cliente se manca; chiede con il riquadro delle domande quante proposte (1, 2 o 3);
    legge la wiki; lancia i due subagenti in parallelo; unisce in proposte (idea, prompt della scena, copy); mostra
    costo e crediti rimasti del giro e aspetta l'ok; genera con la CLI; mostra le scene e chiede quali tenere.
    Aggiorna la fase a ogni passo.

- [ ] **Passo 1:** scrivi skill e subagenti. Nessuna regola di un cliente dentro i file.
- [ ] **Passo 2:** `claude plugin validate plugins/creativita` → nessun errore.
- [ ] **Passo 3:** prova a secco su Learnn con una statica scelta da Max, fermandosi prima della CLI: proposte e
  costo devono avere senso, e la quarta proposta o la terza in qualità alta devono essere rifiutate.
- [ ] **Passo 4 (Max autorizza la spesa):** una scena vera in qualità media, massimo 6 crediti.
- [ ] **Passo 5:** commit `feat(creativita): giro della creatività fino alla scena`.

### Sezione 4: Brand kit su Figma

Prima: le istruzioni e le skill di Learnn devono essere nella wiki di Otto. Se sono ancora solo su GitHub, ci si ferma
e si chiede a Max come portarle.

**File:**
- Crea: `plugins/creativita/skills/creativita-brand-kit/SKILL.md`, `plugins/creativita/agents/estrai-elementi.md`

**Interfacce:**
- Consuma: wiki di Otto (brand del cliente), `chiedi_a_otto` per le immagini delle sue migliori statiche, MCP di Figma
  (`create_new_file`, `use_figma`, `upload_assets`).
- Produce: file `Giotto - <Cliente>` nel progetto «Giotto», pagina **Brand kit** con componenti chiamati
  `kit/<tipo>/<nome>` (tipi: `logo`, `colore`, `testo`, `elemento`, `immagine`), stili colore e stili di testo; nella
  descrizione del componente del font, il fallback da usare se il font manca.
  - `estrai-elementi`: dalle vecchie creatività propone gli elementi ricorrenti con creatività di origine e riquadro;
    il ritaglio si fa in Figma con il riempimento immagine.

- [ ] **Passo 1:** scrivi skill e subagente. Gli elementi entrano nella pagina solo dopo l'ok della persona in chat.
- [ ] **Passo 2:** `claude plugin validate plugins/creativita`.
- [ ] **Passo 3 (con Max, scrive su Figma):** brand kit di Learnn. Max guarda la pagina e dice se elementi e nomi
  vanno bene.
- [ ] **Passo 4:** commit `feat(creativita): brand kit del cliente su Figma`.

### Sezione 5: Composizione su Figma e giro completo

**File:**
- Modifica: `plugins/creativita/skills/creativita/SKILL.md` (passo finale)

**Interfacce:**
- Consuma: scene tenute (Sezione 3), componenti `kit/...` (Sezione 4).
- Produce: nella pagina `Giro <data> - <statica>` del file del cliente, per ogni proposta tenuta i frame `P<n> 9:16`
  (1080×1920) e `P<n> 1:1` (1080×1080), con i livelli `scena`, `headline`, `testo`, `cta`, `logo` ed elementi come
  istanze del kit. Prima di proporre, la skill guarda le pagine dei giri già fatti per non ripetersi.

- [ ] **Passo 1:** scrivi il passo. Se il font manca, la skill lo dice e usa il fallback del kit.
- [ ] **Passo 2 (con Max, scrive su Figma e spende):** giro completo su Learnn, una proposta in qualità media
  (massimo 6 crediti). Max sposta un testo e cambia un colore a mano: i livelli devono essere separati e modificabili.
- [ ] **Passo 3:** commit `feat(creativita): composizione a livelli su Figma`.

### Sezione 6: Rilascio e prova del team

- [ ] **Passo 1:** versione del plugin in `plugin.json` (minore successiva), `README.md` con comandi e configurazione,
  `task.md` aggiornato.
- [ ] **Passo 2 (Max):** push del ramo, PR e unione su main.
- [ ] **Passo 3 (Max):** posti Full su Figma per chi usa la creatività e accesso al progetto «Giotto»; credenziali
  dell'account Higgsfield dell'agenzia date in privato.
- [ ] **Passo 4:** Sofia o Elisa: aggiornano il plugin, `/creativita configura`, un giro da sole. Si annota cosa le ha
  fermate.
