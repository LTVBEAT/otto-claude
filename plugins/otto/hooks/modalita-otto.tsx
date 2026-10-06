// La fascia «Stai parlando con Otto» sopra il prompt, con l'icona di Otto.
// La modalità la gestisce modalita-otto.sh, che scrive «on» in un file per sessione: qui lo si legge
// dopo ogni prompt e si disegna la fascia. Dove le mod non si caricano, la modalità va lo stesso.
import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

const attiva = atom({ plugin: 'otto', key: 'attiva' } as const, false)

// Otto a blocchi per l'app desktop, che non ha Image e non mostra un PNG messo dentro un SVG.
const OTTO_SVG =
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16" shape-rendering="crispEdges"><rect x="5" y="1" width="6" height="1" fill="#222"/><rect x="4" y="2" width="8" height="2" fill="#222"/><rect x="4" y="4" width="10" height="1" fill="#222"/><rect x="7" y="2" width="3" height="1" fill="#ddd"/><rect x="4" y="5" width="8" height="7" fill="#E8673F"/><rect x="2" y="7" width="2" height="2" fill="#E8673F"/><rect x="12" y="7" width="2" height="2" fill="#E8673F"/><rect x="6" y="6" width="1" height="1" fill="#111"/><rect x="9" y="6" width="1" height="1" fill="#111"/><rect x="12" y="9" width="2" height="3" fill="#C9B48A"/><rect x="3" y="9" width="1" height="3" fill="#333"/><rect x="4" y="12" width="1" height="3" fill="#D45A35"/><rect x="6" y="12" width="1" height="3" fill="#D45A35"/><rect x="9" y="12" width="1" height="3" fill="#D45A35"/><rect x="11" y="12" width="1" height="3" fill="#D45A35"/></svg>'

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
    const { Box, Image, Svg, Text } = $.ui.resolve(e)

    // L'app desktop non ha Image: lì Otto è disegnato a blocchi in SVG. Nei terminali senza la
    // grafica kitty l'Image resta uno spazio vuoto.
    return (
      <Box flexDirection="row" alignItems="center" gap={1}>
        {e.surface === 'desktop' && <Svg source={OTTO_SVG} width={24} height={24} alt=" " />}
        {icona && e.surface !== 'desktop' && <Image source={{ png: icona }} columns={4} rows={2} alt=" " />}
        <Text color="success" bold>Stai parlando con Otto</Text>
        <Text dimColor>· /otto off per tornare a Claude · /otto help</Text>
      </Box>
    )
  })
}
