// End-to-end checks of the rendered page (quarto render; serve _site/).
// Usage: node tests/e2e/e2e.js http://localhost:8765/ [screenshot dir]
const { chromium } = require('playwright');
const fs = require('fs');
const BASE = process.argv[2] || 'http://localhost:8765/';
const OUT = process.argv[3] || require('os').tmpdir();

(async () => {
  const results = [];
  try {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 }, acceptDownloads: true });
  const errors = [];
  page.on('pageerror', (e) => errors.push('pageerror: ' + e.message));
  page.on('console', (m) => { if (m.type() === 'error') errors.push('console: ' + m.text()); });

  // wait until the counter is stable (reactable debounces search internally)
  const count = async () => {
    const read = async () => parseInt((await page.textContent('#agt-count')).match(/^(\d+)/)[1], 10);
    await page.waitForTimeout(300); // let the debounced search start
    let prev = -1, cur = await read();
    while (cur !== prev) { await page.waitForTimeout(400); prev = cur; cur = await read(); }
    return cur;
  };
  const check = (name, cond, info) => { results.push(`${cond ? 'PASS' : 'FAIL'} ${name}${info ? ' (' + info + ')' : ''}`); };
  const setMulti = (id, values) => page.evaluate(([id, v]) => document.getElementById(id).tomselect.setValue(v), [id, values]);
  const setInput = (id, v) => page.evaluate(([id, v]) => { const el = document.getElementById(id); el.value = v; el.dispatchEvent(new Event('change')); }, [id, v]);
  const setCheck = (id, v) => page.evaluate(([id, v]) => { const el = document.getElementById(id); el.checked = v; el.dispatchEvent(new Event('change')); }, [id, v]);

  await page.goto(BASE);
  await page.waitForFunction(() => /\d+ of \d+/.test(document.getElementById('agt-count')?.textContent || ''));
  const total = await count();
  const allRows = parseInt((await page.textContent('#agt-count')).match(/of (\d+)/)[1], 10);
  check('initial count shows every row', total > 0 && total === allRows, total);
  check('Tom Select loaded', await page.evaluate(() => !!document.getElementById('agt-f-domain').tomselect));
  await page.screenshot({ path: `${OUT}/desktop-light.png` });

  // search + clear (the original bug)
  await page.fill('#agt-search', 'soil moisture');
  const nSearch = await count();
  check('search narrows', nSearch > 0 && nSearch < total, nSearch);
  await page.fill('#agt-search', 'soil');
  const nSoil = await count();
  check('shorter search broadens', nSoil >= nSearch, nSoil);
  await page.fill('#agt-search', '');
  check('cleared search restores all rows', (await count()) === total);

  // each multi select
  for (const [id, v] of [['agt-f-domain', ['Soil']], ['agt-f-name', ['SoilGrids 2.0']], ['agt-f-tags', ['groundwater']], ['agt-f-coverage_spatial', ['Europe']], ['agt-f-access', ['registration']], ['agt-f-data_type', ['vector']], ['agt-f-parameter', ['2m temperature']]]) {
    await setMulti(id, v);
    const n = await count();
    check(`${id} narrows`, n > 0 && n < total, n);
    await setMulti(id, []);
    check(`${id} cleared restores`, (await count()) === total);
  }
  // combined: domain OR within field
  await setMulti('agt-f-domain', ['Soil', 'Hydrogeology']);
  const nTwo = await count();
  await setMulti('agt-f-domain', ['Soil']);
  check('two domains >= one domain', nTwo > (await count()), nTwo);
  await setMulti('agt-f-domain', []);

  // spatial slider
  await setInput('agt-f-spatial', '300');
  const nSpatial = await count();
  const label = await page.textContent('#agt-f-spatial-out');
  check('spatial slider narrows', nSpatial < total, `${nSpatial} at ${label}`);
  await setInput('agt-f-spatial', '1000');
  check('spatial slider max restores', (await count()) === total);

  // temporal
  await setInput('agt-f-temporal', '2'); // daily
  const nDaily = await count();
  check('temporal daily narrows', nDaily < total && nDaily > 0, nDaily);
  await setCheck('agt-f-static', false);
  const nDailyNoStatic = await count();
  check('excluding static narrows further', nDailyNoStatic < nDaily, nDailyNoStatic);
  await setInput('agt-f-temporal', '');
  await setCheck('agt-f-static', true);
  check('temporal cleared restores', (await count()) === total);

  // period
  await setInput('agt-f-from', '1960');
  await setInput('agt-f-to', '1970');
  const nPeriod = await count();
  check('period narrows', nPeriod < total, nPeriod);
  await setCheck('agt-f-undated', false);
  const nPeriodDated = await count();
  check('excluding undated narrows further', nPeriodDated < nPeriod, nPeriodDated);
  check('period label', (await page.textContent('#agt-f-period-out')) === '1960 – 1970');
  await setInput('agt-f-from', await page.getAttribute('#agt-f-from', 'min'));
  await setInput('agt-f-to', await page.getAttribute('#agt-f-to', 'max'));
  check('period slider at full range restores', (await count()) === total);
  check('period label reset', (await page.textContent('#agt-f-period-out')) === 'any');
  await setCheck('agt-f-undated', true);

  // reset after combining several filters
  await page.fill('#agt-search', 'temperature');
  await setMulti('agt-f-domain', ['Climate & atmosphere']);
  await setInput('agt-f-spatial', '980');
  const nCombined = await count();
  const url = page.url();
  check('URL reflects state', /q=temperature/.test(url) && /domain=/.test(url), url.split('?')[1]);
  await page.click('#agt-reset');
  check('reset restores all rows', (await count()) === total);
  check('reset clears URL', !page.url().includes('?'));

  // URL restore
  await page.goto(url);
  await page.waitForFunction(() => /\d+ of \d+/.test(document.getElementById('agt-count')?.textContent || ''));
  check('URL restore reproduces result', nCombined > 0 && (await count()) === nCombined, `${await count()} vs ${nCombined}`);
  check('URL restore fills controls', (await page.inputValue('#agt-search')) === 'temperature');
  await page.click('#agt-reset');

  // download
  await setMulti('agt-f-domain', ['Soil']);
  const nSoilDomain = await count();
  const [dl] = await Promise.all([page.waitForEvent('download'), page.click('#agt-download')]);
  const csv = fs.readFileSync(await dl.path(), 'utf8');
  const lines = csv.trim().split('\n');
  check('CSV contains filtered rows only', lines.length - 1 === nSoilDomain, `${lines.length - 1} rows`);
  check('CSV has raw metadata columns', lines[0].startsWith('"id","name","parameter"') || lines[0].startsWith('id,name,parameter'), lines[0].slice(0, 60));
  await page.click('#agt-reset');

  // details + grouping
  await page.click('.rt-expander-button');
  check('row details open', await page.isVisible('.agt-details'));
  await page.screenshot({ path: `${OUT}/desktop-details.png` });
  await page.click('#agt-group');
  await page.waitForTimeout(300);
  check('group by dataset', (await page.$$('.rt-tr-group')).length > 0 && (await count()) === total);
  await page.screenshot({ path: `${OUT}/desktop-grouped.png` });
  await page.click('#agt-group');

  // dark + mobile
  const dark = await browser.newPage({ viewport: { width: 1440, height: 900 }, colorScheme: 'dark' });
  await dark.goto(BASE);
  await dark.waitForTimeout(800);
  check('dark mode body class', await dark.evaluate(() => document.body.classList.contains('quarto-dark')));

  // hovered rows keep readable text (WCAG contrast >= 4.5) in both themes
  for (const [name, pg] of [['light', page], ['dark', dark]]) {
    const row = pg.locator('.rt-tbody .rt-tr').nth(1);
    await row.hover();
    await pg.waitForTimeout(150);
    const ratio = await row.evaluate((r) => {
      const rgb = (c) => c.match(/\d+(\.\d+)?/g).slice(0, 3).map(Number);
      const lum = (c) => { const [R, G, B] = rgb(c).map((v) => { v /= 255; return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4); }); return 0.2126 * R + 0.7152 * G + 0.0722 * B; };
      const s = getComputedStyle(r);
      const [a, b] = [lum(s.backgroundColor), lum(s.color)].sort((x, y) => y - x);
      return (a + 0.05) / (b + 0.05);
    });
    check(`hovered row readable (${name})`, ratio >= 4.5, ratio.toFixed(1));
  }
  await dark.screenshot({ path: `${OUT}/desktop-dark.png` });
  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 }, isMobile: true });
  await mobile.goto(BASE);
  await mobile.waitForTimeout(800);
  const overflow = await mobile.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
  check('mobile: no horizontal page scroll', overflow <= 0, overflow);
  check('mobile: filters collapsed', await mobile.evaluate(() => document.getElementById('agt-filters').hidden));
  await mobile.screenshot({ path: `${OUT}/mobile.png`, fullPage: false });

  check('no JS errors', errors.length === 0, errors.join(' | '));
  await browser.close();
  } catch (e) { results.push('CRASH ' + e.message.split('\n')[0]); }
  console.log(results.join('\n'));
  process.exit(results.some((r) => !r.startsWith('PASS')) ? 1 : 0);
})();
