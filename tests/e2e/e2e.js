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

  // standard variables, synonyms, licence
  await setMulti('agt-f-variable', ['precipitation']);
  const nPrecip = await count();
  check('variable filter narrows', nPrecip > 3 && nPrecip < total, nPrecip);
  const precipDatasets = parseInt((await page.textContent('#agt-count')).match(/in (\d+) datasets/)[1], 10);
  check('variable filter spans several datasets', precipDatasets >= 5, precipDatasets);
  await setMulti('agt-f-variable', []);
  check('variable cleared restores', (await count()) === total);
  await page.fill('#agt-search', 'Grundwasserneubildung');
  const nSyn = await count();
  check('German synonym search finds recharge', nSyn > 0 && nSyn < 10, nSyn);
  await page.fill('#agt-search', '');

  // bilingual dictionary: every term maps to its own concept, and English and
  // German terms of a concept return the same rows
  const dict = await page.evaluate(() => {
    const cfg = JSON.parse(document.getElementById('agt-config').textContent);
    const concepts = cfg.dictionary.map((t) => [].concat(t));
    const data = Reactable.getState('agt').data.map((v) => ({ values: v }));
    const keys = (q) => AGT_search(data, q).map((r) => r.values.row_key).sort().join('|');
    const wrongConcept = [];
    const unequal = [];
    concepts.forEach((terms, i) => {
      terms.forEach((t) => {
        const g = AGT_parseQuery(t);
        if (g.length !== 1 || g[0].concept !== i) wrongConcept.push(t);
      });
      const first = keys(terms[0]);
      terms.slice(1).forEach((t) => { if (keys(t) !== first) unequal.push(terms[0] + ' / ' + t); });
    });
    return { n: concepts.length, wrongConcept, unequal };
  });
  check(`every dictionary term maps to its concept (${dict.n} concepts)`, dict.wrongConcept.length === 0, dict.wrongConcept.join(', '));
  check('all terms of a concept return identical rows', dict.unequal.length === 0, dict.unequal.slice(0, 5).join('; '));
  const searchCount = async (q) => { await page.fill('#agt-search', q); return count(); };
  const nNieder = await searchCount('Niederschlag');
  check('"Niederschlag" = "precipitation"', nNieder > 0 && nNieder === (await searchCount('precipitation')), nNieder);
  check('"Dürre" = "Duerre" = "drought"', (await searchCount('Dürre')) === (await searchCount('Duerre')) && (await searchCount('Duerre')) === (await searchCount('drought')));
  check('"Grundwasserstände" finds groundwater levels', (await searchCount('Grundwasserstände')) > 0);
  await searchCount('drought');
  check('"drought" finds the Dürremonitor', await page.evaluate(() => Reactable.getState('agt').sortedData.some((r) => r.id === 'ufz-duerremonitor')));
  check('"rain" does not match terrain/drainage', !(await page.evaluate(() => AGT_search(Reactable.getState('agt').data.map((v) => ({ values: v })), 'rain').some((r) => /terrain|drainage/i.test(r.values.parameter)))));
  await page.fill('#agt-search', '');
  check('cleared dictionary search restores all rows', (await count()) === total);

  // publisher column + filter
  check('publisher column shown', await page.$$eval('.rt-th', (ths) => ths.some((th) => th.textContent.trim() === 'Publisher')));
  await setMulti('agt-f-publisher_label', ['DWD']);
  const nDwd = await count();
  const onlyDwd = await page.evaluate(() => Reactable.getState('agt').sortedData.every((r) => r.publisher_label === 'DWD'));
  check('publisher filter keeps only DWD datasets', nDwd > 0 && onlyDwd, nDwd);
  await setMulti('agt-f-publisher_label', []);
  check('publisher filter cleared restores', (await count()) === total);
  check('"Deutscher Wetterdienst" = "DWD"', (await searchCount('Deutscher Wetterdienst')) === (await searchCount('DWD')) && (await count()) > 0);
  await page.fill('#agt-search', '');

  await setMulti('agt-f-license_class', ['non-commercial']);
  const nNc = await count();
  check('licence filter narrows', nNc > 0 && nNc < total, nNc);
  await setMulti('agt-f-license_class', []);

  // presets
  const presets = await page.$$eval('.agt-preset', (bs) => bs.map((b) => b.textContent));
  for (let i = 0; i < presets.length; i++) {
    await page.click(`.agt-preset >> nth=${i}`);
    const n = await count();
    const pressed = await page.getAttribute(`.agt-preset >> nth=${i}`, 'aria-pressed');
    check(`preset "${presets[i]}" narrows and is active`, n > 0 && n < total && pressed === 'true', n);
  }
  await page.click('.agt-preset:text-is("Crop types")');
  await count();
  const cropIds = await page.evaluate(() => Array.from(new Set(Reactable.getState('agt').sortedData.map((r) => r.id))));
  const expectedCrops = ['eucropmap', 'clms-crop-types', 'dlr-croptypes', 'thuenen-crop-types', 'worldcereal-2021'];
  check('crop types preset lists the crop maps', expectedCrops.every((id) => cropIds.includes(id)), cropIds.join(', '));
  check('"Feldfrucht" = "crop type"', (await searchCount('Feldfrucht')) === (await searchCount('crop type')));
  await page.fill('#agt-search', '');
  await page.click('#agt-reset');
  check('reset after presets restores', (await count()) === total);
  check('no preset active after reset', (await page.$$eval('.agt-preset[aria-pressed="true"]', (b) => b.length)) === 0);

  // study area: Berlin keeps Global/Europe/Germany, drops e.g. CHIRPS (50°S–50°N)
  await page.fill('#agt-f-lat', '52.52');
  await page.fill('#agt-f-lon', '13.40');
  await page.dispatchEvent('#agt-f-lon', 'change');
  const nBerlin = await count();
  const berlinHasChirps = await page.evaluate(() => Reactable.getState('agt').sortedData.some((r) => r.id === 'chirps-2'));
  const berlinHasHyras = await page.evaluate(() => Reactable.getState('agt').sortedData.some((r) => r.id === 'hyras-de'));
  check('study area Berlin narrows', nBerlin < total && nBerlin > 0, nBerlin);
  check('study area keeps German data, drops CHIRPS', berlinHasHyras && !berlinHasChirps);
  check('study area in URL', /lat=52\.52/.test(page.url()));
  await page.fill('#agt-f-lat', '-33.9');
  await page.fill('#agt-f-lon', '18.4');
  await page.dispatchEvent('#agt-f-lon', 'change');
  const capeHasHyras = await page.evaluate(() => Reactable.getState('agt').sortedData.some((r) => r.id === 'hyras-de'));
  check('study area Cape Town drops German data', !capeHasHyras);
  await page.click('#agt-f-map-toggle');
  await page.waitForSelector('#agt-map.leaflet-container');
  const box = await page.locator('#agt-map').boundingBox();
  await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
  await page.waitForTimeout(300);
  check('map click sets the point', (await page.inputValue('#agt-f-lat')) !== '' && !!(await page.$('#agt-map .leaflet-marker-icon')));
  await page.click('#agt-f-area-clear');
  check('clearing study area restores', (await count()) === total);
  await page.click('#agt-f-map-toggle');

  // shortlist
  await page.evaluate(() => { try { localStorage.removeItem('agt-shortlist'); } catch (e) {} });
  const boxes = page.locator('.rt-tbody .rt-td-select input[type="checkbox"]');
  for (let i = 0; i < 3; i++) await boxes.nth(i).check();
  await page.waitForTimeout(200);
  check('shortlist bar shows 3', /^3 parameters/.test(await page.textContent('#agt-shortlist-count')));
  const [sdl] = await Promise.all([page.waitForEvent('download'), page.click('#agt-shortlist-csv')]);
  const scsv = fs.readFileSync(await sdl.path(), 'utf8').trim().split('\n');
  check('shortlist CSV has the 3 rows', scsv.length - 1 === 3, scsv.length - 1);
  const bib = await page.evaluate(() => window.AGT_copyBibtex());
  check('BibTeX has one entry per shortlisted dataset', (bib.match(/^@/gm) || []).length >= 1, (bib.match(/^@/gm) || []).length);
  await page.click('#agt-shortlist-show');
  check('show only shortlist', (await count()) === 3);
  await page.reload();
  await page.waitForFunction(() => /\d+ of \d+/.test(document.getElementById('agt-count')?.textContent || ''));
  await page.waitForTimeout(500);
  check('shortlist survives reload', /^3 parameters/.test(await page.textContent('#agt-shortlist-count')));
  await page.click('#agt-shortlist-clear');
  await page.waitForTimeout(200);
  check('shortlist cleared', await page.evaluate(() => document.getElementById('agt-shortlist').hidden) && (await count()) === total);

  // details + grouping
  await setMulti('agt-f-name', ['SoilGrids 2.0']);
  await page.click('.rt-expander-button');
  check('row details open', await page.isVisible('.agt-details'));
  await page.waitForSelector('.agt-footprint.leaflet-container', { timeout: 5000 }).catch(() => {});
  check('footprint map in details', !!(await page.$('.agt-footprint.leaflet-container')));
  if (await page.$('.agt-snippet-tab')) {
    const tabs = await page.$$('.agt-snippet-tab');
    if (tabs.length > 1) { await tabs[1].click(); }
    check('snippet tab switches', (await page.$$eval('.agt-snippet:not([hidden])', (e) => e.length)) === 1);
  }
  await page.screenshot({ path: `${OUT}/desktop-details.png` });
  await setMulti('agt-f-name', []);
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
