// La fascia «Creazione creatività - <fase>» sopra il prompt.
// La creazione la gestisce comandi-creativita.sh, che scrive la fase in un file per sessione: qui lo si legge
// dopo ogni prompt e, a creazione accesa, dopo ogni strumento, perché la skill cambia fase durante il turno.
// Dove le mod non si caricano, la creazione va lo stesso.
import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

// La fase del giro; vuota = creazione spenta.
const fase = atom({ plugin: 'creativita', key: 'fase' } as const, '')
// Quando la creazione si accende la scritta pulsa: 0 = ferma, poi un battito ogni 300 ms fino a BATTITI.
const battito = atom({ plugin: 'creativita', key: 'battito' } as const, 0)
const BATTITI = 7
// Solo queste finiscono nella fascia: il file lo scrive il modello, e un testo qualsiasi non si mostra.
const FASI = ['analisi', 'proposte', 'scena', 'figma']

async function leggiFase($: EngineInterface) {
  const casa = await $.env.get('HOME')
  const sessione = await $.session.id()
  try {
    const testo = (await $.fs.read(`${casa}/.claude/plugins/data/creativita-ltvbeat/modalita/${sessione}`)).trim()
    return testo === '' ? 'accesa' : testo
  } catch {
    return ''
  }
}

async function aggiorna($: EngineInterface) {
  const adesso = await leggiFase($)
  const eraAccesa = (await read($, fase)) !== ''
  await update($, fase, () => adesso)
  if (adesso !== '' && !eraAccesa) {
    await update($, battito, () => 1)
    const pulsa = $.clock.every(300, () => {
      void update($, battito, n => {
        if (n >= BATTITI) {
          pulsa.cancel()
          return 0
        }
        return n + 1
      })
    })
  }
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const esito = await next(e)
    await update($, fase, () => '')
    return esito
  })

  on('prompt.submit', async ($, e, next) => {
    const esito = await next(e)
    await aggiorna($).catch(() => undefined)
    return esito
  })

  // Passa da ogni strumento: un errore della fascia non deve mai toccare il risultato.
  on('tool.call', async ($, e, next) => {
    const esito = await next(e)
    if ((await read($, fase)) !== '') await aggiorna($).catch(() => undefined)
    return esito
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const adesso = await read($, fase)
    if (adesso === '') {
      return next(e)
    }
    const { Box, Text } = $.ui.resolve(e)
    const passo = await read($, battito)
    return (
      <Box flexDirection="row" alignItems="center" gap={1}>
        <Text>🎨</Text>
        <Text color={passo % 2 === 1 ? 'claude' : 'success'} bold>
          {FASI.includes(adesso) ? `Creazione creatività - ${adesso}` : 'Creazione creatività'}
        </Text>
        {passo === 0 && <Text dimColor>· /creativita off per uscire · /creativita help</Text>}
      </Box>
    )
  })
}
