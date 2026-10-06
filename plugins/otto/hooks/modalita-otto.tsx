// La fascia «Stai parlando con Otto» sopra il prompt, con l'icona di Otto.
// La modalità la gestisce modalita-otto.sh, che scrive «on» in un file per sessione: qui lo si legge
// dopo ogni prompt e si disegna la fascia. Dove le mod non si caricano, la modalità va lo stesso.
import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

const attiva = atom({ plugin: 'otto', key: 'attiva' } as const, false)

// Nell'app desktop l'icona è il PNG dentro un SVG (provato da Max: l'app lo disegna).
const pngInSvg = (base64: string) =>
  `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 96 96" width="96" height="96">` +
  `<image width="96" height="96" href="data:image/png;base64,${base64}" xlink:href="data:image/png;base64,${base64}"/></svg>`

async function leggiIcona($: EngineInterface) {
  try {
    return (await $.fs.read(`${$.plugin.root}/assets/otto.png`, { as: 'bytes' })).base64
  } catch {
    return null
  }
}

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
    icona = await leggiIcona($)
    return esito
  })

  on('prompt.submit', async ($, e, next) => {
    const esito = await next(e)
    // Nell'app desktop la mod di un plugin installato può caricarsi a sessione già avviata, senza
    // vedere session.start: l'icona si legge anche qui, prima che la fascia si ridisegni.
    if (!icona) {
      icona = await leggiIcona($)
    }
    const accesa = await leggiStato($)
    await update($, attiva, () => accesa)
    return esito
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (!(await read($, attiva))) {
      return next(e)
    }
    const { Box, Image, Svg, Text } = $.ui.resolve(e)

    // Solo il terminale ha Image. Con un controllo su e.surface === 'desktop' l'app non mostrava
    // l'icona: si sceglie come la mod di prova che funziona, terminale contro tutto il resto.
    return (
      <Box flexDirection="row" alignItems="center" gap={1}>
        {icona && e.surface === 'terminal' && <Image source={{ png: icona }} columns={4} rows={2} alt=" " />}
        {icona && e.surface !== 'terminal' && <Svg source={pngInSvg(icona)} width={24} height={24} alt=" " />}
        <Text color="success" bold>Stai parlando con Otto</Text>
        <Text dimColor>· /otto off per tornare a Claude · /otto help</Text>
      </Box>
    )
  })
}
