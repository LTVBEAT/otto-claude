// La fascia «Stai parlando con Otto» sopra il prompt, con l'icona di Otto.
// La modalità la gestisce modalita-otto.sh, che scrive «on» in un file per sessione: qui lo si legge
// dopo ogni prompt e si disegna la fascia. Dove le mod non si caricano, la modalità va lo stesso.
import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

const attiva = atom({ plugin: 'otto', key: 'attiva' } as const, false)

async function leggiStato($: EngineInterface) {
  const casa = await $.env.get('HOME')
  const sessione = await $.session.id()
  try {
    const testo = await $.fs.read(`${casa}/.claude/plugins/data/otto-ltvbeat/modalita/${sessione}`)
    return testo.trim() === 'on'
  } catch {
    return false
  }
}

export const register: Register = on => {
  // L'icona viaggia come PNG in base64: un percorso di file lo sa leggere solo il terminale.
  let icona: string | null = null

  on('session.start', async ($, e, next) => {
    const esito = await next(e)
    await update($, attiva, () => false)
    try {
      icona = (await $.fs.read(`${$.plugin.root}/assets/otto.png`, { as: 'bytes' })).base64
    } catch {
      icona = null
    }
    return esito
  })

  on('prompt.submit', async ($, e, next) => {
    const esito = await next(e)
    const accesa = await leggiStato($)
    await update($, attiva, () => accesa)
    return esito
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (!(await read($, attiva))) {
      return next(e)
    }
    const { Box, Image, Text } = $.ui.resolve(e)

    // Nell'app l'icona si vede; nei terminali senza grafica kitty resta uno spazio vuoto.
    return (
      <Box flexDirection="row" alignItems="center" gap={1}>
        {icona && <Image source={{ png: icona }} columns={4} rows={2} alt=" " />}
        <Text color="success" bold>Stai parlando con Otto</Text>
        <Text dimColor>· /otto off per tornare a Claude · /otto help</Text>
      </Box>
    )
  })
}
