// La fascia «Stai parlando con Otto» sopra il prompt, con l'icona di Otto.
// La modalità la gestisce modalita-otto.sh, che scrive «on» in un file per sessione: qui lo si legge
// dopo ogni prompt e si disegna la fascia. Dove le mod non si caricano, la modalità va lo stesso.
import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import { OTTO_PNG } from './icona'

const attiva = atom({ plugin: 'otto', key: 'attiva' } as const, false)
// Quando la modalità si accende la scritta pulsa: 0 = ferma, poi un battito ogni 300 ms fino a BATTITI.
const battito = atom({ plugin: 'otto', key: 'battito' } as const, 0)
const BATTITI = 7

// Nell'app desktop l'icona è il PNG dentro un SVG (provato da Max: l'app lo disegna). Il PNG sta in
// icona.ts e non si legge da assets/: nel plugin installato la lettura falliva e l'icona non c'era.
const pngInSvg = (base64: string) =>
  `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 96 96" width="96" height="96">` +
  `<image width="96" height="96" href="data:image/png;base64,${base64}" xlink:href="data:image/png;base64,${base64}"/></svg>`

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
  on('session.start', async ($, e, next) => {
    const esito = await next(e)
    await update($, attiva, () => false)
    return esito
  })

  on('prompt.submit', async ($, e, next) => {
    const esito = await next(e)
    const accesa = await leggiStato($)
    const eraAccesa = await read($, attiva)
    await update($, attiva, () => accesa)
    if (accesa && !eraAccesa) {
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
    return esito
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (!(await read($, attiva))) {
      return next(e)
    }
    const { Box, Image, Svg, Text } = $.ui.resolve(e)
    const fase = await read($, battito)

    // Solo il terminale ha Image. Con un controllo su e.surface === 'desktop' l'app non mostrava
    // l'icona: si sceglie come la mod di prova che funziona, terminale contro tutto il resto.
    return (
      <Box flexDirection="row" alignItems="center" gap={1}>
        {e.surface === 'terminal' && <Image source={{ png: OTTO_PNG }} columns={4} rows={2} alt=" " />}
        {e.surface !== 'terminal' && <Svg source={pngInSvg(OTTO_PNG)} width={24} height={24} alt=" " />}
        <Text color={fase % 2 === 1 ? 'claude' : 'success'} bold>Stai parlando con Otto</Text>
        {fase === 0 && <Text dimColor>· /otto off per tornare a Claude · /otto help</Text>}
      </Box>
    )
  })
}
