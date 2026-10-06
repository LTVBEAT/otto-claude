import { expect, mock, test } from 'claude-code/testing'

// Il plugin chiede il token: nei test basta uno finto.
const token = { options: { token: 'finto' } }

const props = { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 100, scroll: { offset: 0 } }

// La fascia del plugin vero, accesa: l'icona c'è su ogni superficie, senza leggere niente da disco.
for (const [surface, icona] of [['terminal', 'Image'], ['desktop', 'Svg']] as const) {
  test(`la fascia di Otto ha l'icona su ${surface}`, token, async ($, on) => {
    on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
      const { Text } = $.ui.resolve(e)
      return <Text> </Text>
    })
    // /otto on: il file della modalità dice «on».
    on('env.get', () => ({ value: '/casa' }))
    on('session.id', () => ({ value: 'sessione-prova' }))
    on('fs.read', () => ({ value: 'on\n' }))
    on('prompt.submit', (_$, e) => e)
    await $.prompt.submit({ text: 'ciao' })
    const disegno = await $.ui.mount({ plugin: 'otto', surface, component: 'AbovePrompt', props })
    expect(await disegno.find({ text: 'Stai parlando con Otto' })).toBeDefined()
    expect(await disegno.find({ type: icona })).toBeDefined()
  })
}

test('a modalità spenta la fascia non c\'è', token, async ($, on) => {
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text>vuoto</Text>
  })
  const disegno = await $.ui.mount({ plugin: 'otto', surface: 'desktop', component: 'AbovePrompt', props })
  expect(await disegno.find({ text: 'Stai parlando con Otto' })).toBeUndefined()
})

test('quando la modalità si accende la scritta pulsa, poi torna ferma con i comandi', token, async ($, on) => {
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text> </Text>
  })
  const orologio = mock.clock(on)
  on('env.get', () => ({ value: '/casa' }))
  on('session.id', () => ({ value: 'sessione-prova' }))
  on('fs.read', () => ({ value: 'on\n' }))
  on('prompt.submit', (_$, e) => e)
  await $.prompt.submit({ text: '/otto on' })
  const disegno = await $.ui.mount({ plugin: 'otto', surface: 'desktop', component: 'AbovePrompt', props })

  const colore = async () => (await disegno.drawn()).children.find(c => c.type === 'Text')?.props.color
  expect(await colore()).toBe('claude')
  expect(await disegno.find({ text: '· /otto off per tornare a Claude · /otto help' })).toBeUndefined()

  await orologio.advance(300)
  expect(await colore()).toBe('success')

  await orologio.advance(3000)
  expect(await colore()).toBe('success')
  expect(await disegno.find({ text: '· /otto off per tornare a Claude · /otto help' })).toBeDefined()
})
