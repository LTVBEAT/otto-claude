import { expect, test } from 'claude-code/testing'

// Il plugin chiede il token: nei test basta uno finto.
const token = { options: { token: 'finto' } }

// La fascia com'è disegnata in modalita-otto.tsx, sempre accesa: serve a vedere cosa accetta ogni
// superficie. L'app desktop non ha Image, e lì l'icona è un Svg.
const fascia = {
  name: 'fascia-prova',
  register: on => {
    on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
      const { Box, Image, Svg, Text } = $.ui.resolve(e)
      const png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
      const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><rect x="4" y="5" width="8" height="7" fill="#E8673F"/></svg>'
      return (
        <Box flexDirection="row" alignItems="center" gap={1}>
          {e.surface !== 'terminal' && <Svg source={svg} width={24} height={24} alt=" " />}
          {e.surface === 'terminal' && <Image source={{ png }} columns={4} rows={2} alt=" " />}
          <Text color="success" bold>Stai parlando con Otto</Text>
          <Text dimColor>· /otto off per tornare a Claude · /otto help</Text>
        </Box>
      )
    })
  },
}

const props = { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 100, scroll: { offset: 0 } }

for (const [surface, icona] of [['terminal', 'Image'], ['desktop', 'Svg']] as const) {
  test(`la fascia con l'icona si disegna su ${surface}`, { ...token, plugins: [fascia] }, async ($, on) => {
    on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
      const { Text } = $.ui.resolve(e)
      return <Text> </Text>
    })
    const disegno = await $.ui.mount({ plugin: 'fascia-prova', surface, component: 'AbovePrompt', props })
    expect(await disegno.find({ text: 'Stai parlando con Otto' })).toBeDefined()
    expect(await disegno.find({ type: icona })).toBeDefined()
  })
}
