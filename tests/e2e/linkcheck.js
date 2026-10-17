// Real-browser audit of all dataset links (download_url, doc_url, DOI).
// Unlike a plain HTTP check it follows JavaScript redirects, gets past most
// bot filters and recognises "soft 404s" (status 200, but a not-found page or a
// redirect from a deep link to a home/news page).
//
// Usage: node tests/e2e/linkcheck.js [metadata/datasets.csv] [report.tsv]
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const CSV = process.argv[2] || path.join(__dirname, '..', '..', 'metadata', 'datasets.csv');
const REPORT = process.argv[3] || 'linkcheck-report.tsv';
const CONCURRENCY = 4;

// minimal RFC 4180 CSV parser (quoted fields, embedded commas/newlines)
function parseCsv(text) {
  const rows = [];
  let row = [], field = '', quoted = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (quoted) {
      if (c === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (c === '"') quoted = false;
      else field += c;
    } else if (c === '"') quoted = true;
    else if (c === ',') { row.push(field); field = ''; }
    else if (c === '\n') { row.push(field); rows.push(row); row = []; field = ''; }
    else if (c !== '\r') field += c;
  }
  if (field || row.length) { row.push(field); rows.push(row); }
  const [header, ...body] = rows;
  return body.filter((r) => r.length > 1).map((r) => Object.fromEntries(header.map((h, i) => [h, r[i] || ''])));
}

const SOFT_404_TITLE = /not found|404|page (doesn|does not|cannot be)|no longer (available|exists)|nicht gefunden|request rejected|error/i;

function softRedirect(from, to) {
  try {
    const a = new URL(from), b = new URL(to);
    const deep = a.pathname.replace(/\/$/, '').split('/').filter(Boolean).length >= 2;
    const landed = b.pathname.replace(/\/$/, '');
    // single-page apps route with #/… – not a redirect to the home page
    return deep && !b.hash && (landed === '' || /^\/(\w{2}\/)?(news|home|index(\.html?)?)$/.test(landed));
  } catch (e) { return false; }
}

async function check(context, link) {
  const page = await context.newPage();
  const result = { ...link, status: '', final: '', title: '', verdict: '' };
  try {
    const download = page.waitForEvent('download', { timeout: 45000 }).then(() => 'download').catch(() => null);
    const response = await page.goto(link.url, { waitUntil: 'domcontentloaded', timeout: 45000 })
      .catch((e) => (/Download is starting/.test(e.message) ? 'download' : Promise.reject(e)));
    if (response === 'download' || (await Promise.race([download, Promise.resolve(null)])) === 'download') {
      Object.assign(result, { status: 200, final: link.url, verdict: 'ok (file download)' });
    } else {
      await page.waitForTimeout(1500); // client-side redirects / rendering
      result.status = response ? response.status() : 0;
      result.final = page.url();
      result.title = (await page.title().catch(() => '')).replace(/\s+/g, ' ').trim().slice(0, 100);
      if (result.status >= 400) result.verdict = result.status === 403 ? 'blocked (403)' : 'BROKEN';
      else if (SOFT_404_TITLE.test(result.title)) result.verdict = 'SOFT 404';
      else if (softRedirect(link.url, result.final)) result.verdict = 'SOFT 404 (redirect to home/news)';
      else if (result.final.replace(/\/$/, '') !== link.url.replace(/\/$/, '') && !link.url.includes('doi.org/')) result.verdict = 'ok (redirected)';
      else result.verdict = 'ok';
    }
  } catch (e) {
    // headless Chromium aborts navigation to PDFs and other files: ask directly
    try {
      const res = await context.request.get(link.url, { timeout: 45000, maxRedirects: 10 });
      const type = (res.headers()['content-type'] || '').split(';')[0];
      Object.assign(result, {
        status: res.status(), final: res.url(), title: type,
        verdict: res.ok() ? `ok (${type || 'file'})` : (res.status() === 403 ? 'blocked (403)' : 'BROKEN')
      });
    } catch (e2) {
      Object.assign(result, { verdict: 'BROKEN', title: e.message.split('\n')[0].slice(0, 100) });
    }
  }
  await page.close();
  return result;
}

(async () => {
  const datasets = parseCsv(fs.readFileSync(CSV, 'utf8'));
  const links = [];
  for (const d of datasets) {
    if (d.download_url) links.push({ id: d.id, field: 'download_url', url: d.download_url });
    if (d.doc_url) links.push({ id: d.id, field: 'doc_url', url: d.doc_url });
    if (d.doi) links.push({ id: d.id, field: 'doi', url: 'https://doi.org/' + d.doi });
  }

  const browser = await chromium.launch();
  const context = await browser.newContext({ acceptDownloads: true, locale: 'en-GB' });
  const results = [];
  let next = 0;
  await Promise.all(Array.from({ length: CONCURRENCY }, async () => {
    while (next < links.length) {
      const link = links[next++];
      results.push(await check(context, link));
    }
  }));
  await browser.close();

  results.sort((a, b) => a.id.localeCompare(b.id) || a.field.localeCompare(b.field));
  const columns = ['verdict', 'status', 'id', 'field', 'url', 'final', 'title'];
  fs.writeFileSync(REPORT, [columns.join('\t')].concat(results.map((r) => columns.map((c) => r[c]).join('\t'))).join('\n') + '\n');

  const problems = results.filter((r) => /BROKEN|SOFT/.test(r.verdict));
  const counts = results.reduce((acc, r) => { const k = r.verdict.split(' ')[0]; acc[k] = (acc[k] || 0) + 1; return acc; }, {});
  console.log(`${results.length} links:`, JSON.stringify(counts));
  problems.forEach((r) => console.log(`${r.verdict}\t${r.id}\t${r.field}\t${r.url}\t→ ${r.final}\t${r.title}`));
  console.log(`report: ${REPORT}`);
  process.exit(problems.length ? 1 : 0);
})();
