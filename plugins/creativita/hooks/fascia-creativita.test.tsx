import { expect, mock, test } from 'claude-code/testing'

const props = { hasSurvey: false, isWorking: false, maxRows: 10, bodyColumns: 100, scroll: { offset: 0 } }

// Il file della sessione dice la fase del giro: la fascia la mostra.
for (const surface of ['terminal', 'desktop'] as const) {
  test(`con la fase scena la fascia dice Creazione creatività - scena su ${surface}`, async ($, on) => {
    on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
      const { Text } = $.ui.resolve(e)
      return <Text> </Text>
    })
    on('env.get', () => ({ value: '/casa' }))
    on('session.id', () => ({ value: 'sessione-prova' }))
    on('fs.read', () => ({ value: 'scena\n' }))
    on('prompt.submit', (_$, e) => e)
    await $.prompt.submit({ text: 'riadatta questa statica' })
    const disegno = await $.ui.mount({ plugin: 'creativita', surface, component: 'AbovePrompt', props })
    expect(await disegno.find({ text: 'Creazione creatività - scena' })).toBeDefined()
  })
}

test('a creazione spenta la fascia non c\'è', async ($, on) => {
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text>vuoto</Text>
  })
  on('env.get', () => ({ value: '/casa' }))
  on('session.id', () => ({ value: 'sessione-prova' }))
  on('fs.read', () => { throw new Error('nessun file') })
  on('prompt.submit', (_$, e) => e)
  await $.prompt.submit({ text: 'ciao' })
  const disegno = await $.ui.mount({ plugin: 'creativita', surface: 'desktop', component: 'AbovePrompt', props })
  expect(await disegno.find({ text: 'vuoto' })).toBeDefined()
})

test('la fase si aggiorna durante il turno, dopo uno strumento', async ($, on) => {
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text> </Text>
  })
  let file = 'analisi\n'
  on('env.get', () => ({ value: '/casa' }))
  on('session.id', () => ({ value: 'sessione-prova' }))
  on('fs.read', () => ({ value: file }))
  on('prompt.submit', (_$, e) => e)
  on('tool.call', () => ({ result: { stdout: '', stderr: '', interrupted: false }, isError: false }))
  await $.prompt.submit({ text: '/creativita on' })
  const disegno = await $.ui.mount({ plugin: 'creativita', surface: 'desktop', component: 'AbovePrompt', props })
  expect(await disegno.find({ text: 'Creazione creatività - analisi' })).toBeDefined()

  file = 'figma\n'
  await $.tool.call({ tool: 'Bash', command: 'true' })
  expect(await disegno.find({ text: 'Creazione creatività - figma' })).toBeDefined()
})

test('una fase sconosciuta mostra solo Creazione creatività', async ($, on) => {
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text> </Text>
  })
  on('env.get', () => ({ value: '/casa' }))
  on('session.id', () => ({ value: 'sessione-prova' }))
  on('fs.read', () => ({ value: '<script>\n' }))
  on('prompt.submit', (_$, e) => e)
  await $.prompt.submit({ text: 'ciao' })
  const disegno = await $.ui.mount({ plugin: 'creativita', surface: 'desktop', component: 'AbovePrompt', props })
  expect(await disegno.find({ text: 'Creazione creatività' })).toBeDefined()
})

test('quando si accende la scritta pulsa, poi resta ferma con i comandi', async ($, on) => {
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text> </Text>
  })
  const orologio = mock.clock(on)
  on('env.get', () => ({ value: '/casa' }))
  on('session.id', () => ({ value: 'sessione-prova' }))
  on('fs.read', () => ({ value: 'analisi\n' }))
  on('prompt.submit', (_$, e) => e)
  await $.prompt.submit({ text: '/creativita on' })
  const disegno = await $.ui.mount({ plugin: 'creativita', surface: 'desktop', component: 'AbovePrompt', props })
  const comandi = '· /creativita off per uscire · /creativita help'
  expect(await disegno.find({ text: comandi })).toBeUndefined()
  await orologio.advance(3000)
  expect(await disegno.find({ text: comandi })).toBeDefined()
})
