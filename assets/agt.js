// Filter panel controller for the Awesome Geodata Table.
//
// All filter state lives in `state`. Every change calls apply(), which pushes
// the *complete* state to the table: filters that are off are omitted, so
// clearing an input always brings every row back. The same state is mirrored
// in the URL; presets are stored URLs.
(function () {
  'use strict';

  const cfg = JSON.parse(document.getElementById('agt-config').textContent);
  const TABLE = cfg.tableId;
  const $ = (id) => document.getElementById(id);
  const multiSelects = Array.from(document.querySelectorAll('select[data-kind="multi"]'));
  const presetButtons = Array.from(document.querySelectorAll('.agt-preset'));
  const SLIDER_MAX = 1000;
  const logMin = Math.log10(cfg.spatialMin);
  const logMax = Math.log10(cfg.spatialMax);
  const STORAGE_KEY = 'agt-shortlist';
  const TILES = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  const TILE_ATTRIBUTION = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors';

  const state = {
    search: '',
    multi: {},          // column -> array of selected values
    spatial: null,      // metres; null = off
    temporal: null,     // rank; null = off
    includeStatic: true,
    from: null,
    to: null,
    includeUndated: true,
    lat: null,          // study area point; null = off
    lon: null,
    grouped: false,
    shortlistOnly: false
  };

  // ---- helpers ---------------------------------------------------------------
  const sliderToMetres = (pos) => {
    if (pos >= SLIDER_MAX) return null;
    const m = Math.pow(10, logMin + (pos / SLIDER_MAX) * (logMax - logMin));
    const magnitude = Math.pow(10, Math.floor(Math.log10(m)));
    return Math.round(m / magnitude) * magnitude;   // 1 significant digit
  };
  const metresToSlider = (m) => m == null ? SLIDER_MAX :
    Math.round((Math.log10(m) - logMin) / (logMax - logMin) * SLIDER_MAX);
  const fmtMetres = (m) => m == null ? 'any' : (m >= 1000 ? (m / 1000) + ' km' : m + ' m');
  const toInt = (v) => (v === '' || v == null || isNaN(parseInt(v, 10))) ? null : parseInt(v, 10);
  const toNum = (v, lim) => {
    const x = parseFloat(v);
    return (v === '' || v == null || isNaN(x) || Math.abs(x) > lim) ? null : x;
  };
  const empty = (v) => v == null || (Array.isArray(v) && v.length === 0);
  const round4 = (x) => Math.round(x * 1e4) / 1e4;

  function selectValues(el) {
    if (el.tomselect) return el.tomselect.getValue();
    return Array.from(el.selectedOptions).map((o) => o.value);
  }
  function setSelectValues(el, values) {
    if (el.tomselect) { el.tomselect.setValue(values, true); return; }
    Array.from(el.options).forEach((o) => { o.selected = values.includes(o.value); });
  }
  function flash(btn, text, label) {
    btn.textContent = text;
    setTimeout(() => { btn.textContent = label; }, 1500);
  }
  function copyText(text) {
    if (navigator.clipboard) return navigator.clipboard.writeText(text);
    return Promise.reject(new Error('clipboard unavailable'));
  }

  // ---- read controls -> state -------------------------------------------------
  function readControls() {
    state.search = $('agt-search').value.trim();
    multiSelects.forEach((el) => { state.multi[el.dataset.filter] = selectValues(el); });
    state.spatial = sliderToMetres(+$('agt-f-spatial').value);
    state.temporal = toInt($('agt-f-temporal').value);
    state.includeStatic = $('agt-f-static').checked;
    // handles at the ends of the slider = no limit on that side
    const from = +$('agt-f-from').value, to = +$('agt-f-to').value;
    state.from = from <= cfg.yearMin ? null : from;
    state.to = to >= cfg.yearMax ? null : to;
    state.includeUndated = $('agt-f-undated').checked;
    state.lat = toNum($('agt-f-lat').value, 90);
    state.lon = toNum($('agt-f-lon').value, 180);
    if (state.lat == null || state.lon == null) { state.lat = null; state.lon = null; }
  }

  // ---- state -> controls (used for URL restore, presets and reset) -----------
  function writeControls() {
    $('agt-search').value = state.search;
    multiSelects.forEach((el) => setSelectValues(el, state.multi[el.dataset.filter] || []));
    $('agt-f-spatial').value = metresToSlider(state.spatial);
    $('agt-f-temporal').value = state.temporal == null ? '' : String(state.temporal);
    $('agt-f-static').checked = state.includeStatic;
    $('agt-f-from').value = state.from == null ? cfg.yearMin : state.from;
    $('agt-f-to').value = state.to == null ? cfg.yearMax : state.to;
    updatePeriodSlider();
    $('agt-f-undated').checked = state.includeUndated;
    $('agt-f-lat').value = state.lat == null ? '' : state.lat;
    $('agt-f-lon').value = state.lon == null ? '' : state.lon;
    $('agt-group').setAttribute('aria-pressed', String(state.grouped));
    $('agt-shortlist-show').setAttribute('aria-pressed', String(state.shortlistOnly));
  }

  // label and coloured track between the two handles of the period slider
  function updatePeriodSlider() {
    const from = +$('agt-f-from').value, to = +$('agt-f-to').value;
    const span = cfg.yearMax - cfg.yearMin || 1;
    const fill = $('agt-f-period-fill');
    fill.style.left = ((from - cfg.yearMin) / span * 100) + '%';
    fill.style.right = ((cfg.yearMax - to) / span * 100) + '%';
    $('agt-f-period-out').textContent =
      from <= cfg.yearMin && to >= cfg.yearMax ? 'any' : from + ' – ' + to;
  }

  // ---- state -> table ---------------------------------------------------------
  // the complete filter list; filters that are off are simply omitted
  function tableFilters() {
    const filters = [];
    Object.entries(state.multi).forEach(([id, value]) => { if (!empty(value)) filters.push({ id, value }); });
    if (state.spatial != null) filters.push({ id: 'res_spatial_finest_m', value: state.spatial });
    if (state.temporal != null || !state.includeStatic) {
      filters.push({ id: 'res_temporal_finest_rank', value: { max: state.temporal, includeStatic: state.includeStatic } });
    }
    if (state.from != null || state.to != null) {
      filters.push({ id: 'coverage_start_year', value: { from: state.from, to: state.to, includeUndated: state.includeUndated } });
    }
    if (state.lat != null) filters.push({ id: 'bbox_west', value: { lat: state.lat, lon: state.lon } });
    if (state.shortlistOnly) filters.push({ id: 'row_key', value: shortlistKeys.length ? shortlistKeys : ['\u0000'] });
    return filters;
  }

  let appliedFilters, appliedSearch, appliedGrouped;
  function apply() {
    $('agt-f-spatial-out').textContent = fmtMetres(state.spatial);
    updatePeriodSlider();

    // one state update per change: each setFilter() would re-render the table
    const filters = tableFilters();
    const filtersKey = JSON.stringify(filters);
    if (filtersKey !== appliedFilters) {
      Reactable.setAllFilters(TABLE, filters);
      appliedFilters = filtersKey;
    }
    if (state.search !== appliedSearch) {
      Reactable.setSearch(TABLE, state.search || undefined);
      appliedSearch = state.search;
    }
    if (state.grouped !== appliedGrouped) {
      Reactable.setGroupBy(TABLE, state.grouped ? ['name'] : []);
      appliedGrouped = state.grouped;
    }

    markActiveFields();
    updateStudyMarker();
    writeUrl();
    markActivePreset();
  }

  function markActiveFields() {
    multiSelects.forEach((el) => el.closest('.agt-field').classList.toggle('is-active', !empty(state.multi[el.dataset.filter])));
    $('agt-f-spatial').closest('.agt-field').classList.toggle('is-active', state.spatial != null);
    $('agt-f-temporal').closest('.agt-field').classList.toggle('is-active', state.temporal != null || !state.includeStatic);
    $('agt-f-from').closest('.agt-field').classList.toggle('is-active', state.from != null || state.to != null);
    $('agt-f-lat').closest('.agt-field').classList.toggle('is-active', state.lat != null);
  }

  // ---- URL <-> state ----------------------------------------------------------
  function stateToParams() {
    const p = new URLSearchParams();
    if (state.search) p.set('q', state.search);
    Object.entries(state.multi).forEach(([c, v]) => { if (!empty(v)) p.set(c, v.join('|')); });
    if (state.spatial != null) p.set('spatial', state.spatial);
    if (state.temporal != null) p.set('temporal', state.temporal);
    if (!state.includeStatic) p.set('static', '0');
    if (state.from != null) p.set('from', state.from);
    if (state.to != null) p.set('to', state.to);
    if (!state.includeUndated) p.set('undated', '0');
    if (state.lat != null) { p.set('lat', state.lat); p.set('lon', state.lon); }
    return p;
  }

  function paramsToState(p) {
    state.search = p.get('q') || '';
    multiSelects.forEach((el) => {
      const c = el.dataset.filter;
      state.multi[c] = p.has(c) ? p.get(c).split('|') : [];
    });
    state.spatial = toInt(p.get('spatial'));
    state.temporal = toInt(p.get('temporal'));
    state.includeStatic = p.get('static') !== '0';
    state.from = toInt(p.get('from'));
    state.to = toInt(p.get('to'));
    state.includeUndated = p.get('undated') !== '0';
    state.lat = toNum(p.get('lat'), 90);
    state.lon = toNum(p.get('lon'), 180);
    if (state.lat == null || state.lon == null) { state.lat = null; state.lon = null; }
  }

  function writeUrl() {
    const p = stateToParams();
    if (state.grouped) p.set('group', '1');
    const qs = p.toString();
    history.replaceState(null, '', qs ? '?' + qs : location.pathname + location.hash);
  }

  function readUrl() {
    const p = new URLSearchParams(location.search);
    paramsToState(p);
    state.grouped = p.get('group') === '1';
  }

  function reset() {
    paramsToState(new URLSearchParams());
    state.shortlistOnly = false;
    writeControls();
    apply();
  }

  // ---- presets ----------------------------------------------------------------
  // a preset is active while the current filters equal its query exactly
  const canonical = (p) => Array.from(p.entries())
    .map(([k, v]) => k + '=' + v.split('|').sort().join('|')).sort().join('&');

  function markActivePreset() {
    const current = canonical(stateToParams());
    presetButtons.forEach((b) => {
      b.setAttribute('aria-pressed', String(canonical(new URLSearchParams(b.dataset.query)) === current));
    });
  }

  function applyPreset(btn) {
    const active = btn.getAttribute('aria-pressed') === 'true';
    paramsToState(new URLSearchParams(active ? '' : btn.dataset.query));  // second click clears
    writeControls();
    apply();
  }

  // ---- study area map ---------------------------------------------------------
  let studyMap = null, studyMarker = null;

  function setStudyPoint(lat, lon) {
    $('agt-f-lat').value = lat == null ? '' : round4(lat);
    $('agt-f-lon').value = lon == null ? '' : round4(lon);
    readControls();
    apply();
  }

  function updateStudyMarker() {
    if (!studyMap) return;
    if (state.lat == null) {
      if (studyMarker) { studyMarker.remove(); studyMarker = null; }
      return;
    }
    if (studyMarker) studyMarker.setLatLng([state.lat, state.lon]);
    else studyMarker = L.marker([state.lat, state.lon]).addTo(studyMap);
  }

  function toggleStudyMap() {
    const box = $('agt-map');
    const open = box.hidden;
    box.hidden = !open;
    $('agt-f-map-toggle').setAttribute('aria-expanded', String(open));
    if (!open || !window.L) return;
    if (!studyMap) {
      studyMap = L.map(box, { worldCopyJump: true }).setView(state.lat == null ? [50, 10] : [state.lat, state.lon], 3);
      L.tileLayer(TILES, { maxZoom: 12, attribution: TILE_ATTRIBUTION }).addTo(studyMap);
      studyMap.on('click', (e) => {
        const ll = e.latlng.wrap();
        setStudyPoint(ll.lat, ll.lng);
      });
    }
    studyMap.invalidateSize();
    updateStudyMarker();
  }

  // footprint mini-maps in the row details are created when details open
  function initFootprints(root) {
    if (!window.L) return;
    root.querySelectorAll('.agt-footprint:not([data-ready])').forEach((el) => {
      el.dataset.ready = '1';
      const [w, s, e, n] = el.dataset.bbox.split(',').map(Number);
      const map = L.map(el, {
        zoomControl: false, dragging: false, scrollWheelZoom: false, doubleClickZoom: false,
        boxZoom: false, keyboard: false, touchZoom: false, attributionControl: true
      });
      L.tileLayer(TILES, { maxZoom: 8, attribution: TILE_ATTRIBUTION }).addTo(map);
      const bounds = L.latLngBounds([s, w], [n, e]);
      L.rectangle(bounds, { color: getComputedStyle(document.body).getPropertyValue('--agt-accent').trim() || '#c2185b', weight: 2, fillOpacity: 0.12 }).addTo(map);
      if (e - w >= 359) map.setView([20, 0], 0);
      else map.fitBounds(bounds, { padding: [8, 8] });
      if (state.lat != null) L.circleMarker([state.lat, state.lon], { radius: 4 }).addTo(map);
    });
  }

  // ---- snippets (tabs + copy, delegated) ----------------------------------------
  function onSnippetClick(event) {
    const tab = event.target.closest('.agt-snippet-tab');
    const copy = event.target.closest('.agt-snippet-copy');
    if (!tab && !copy) return;
    const box = event.target.closest('.agt-snippets');
    if (tab) {
      box.querySelectorAll('.agt-snippet-tab').forEach((t) => t.setAttribute('aria-selected', String(t === tab)));
      box.querySelectorAll('.agt-snippet').forEach((pre) => { pre.hidden = pre.dataset.lang !== tab.dataset.lang; });
    } else {
      const visible = box.querySelector('.agt-snippet:not([hidden])');
      copyText(visible.textContent).then(() => flash(copy, 'Copied ✓', 'Copy'), () => flash(copy, 'Copy failed', 'Copy'));
    }
  }

  // ---- shortlist ----------------------------------------------------------------
  // selection is reactable's checkbox column; it is stored by row_key so it
  // survives reloads and data updates
  let shortlistKeys = [];

  function readStoredShortlist() {
    try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); } catch (e) { return []; }
  }
  function storeShortlist() {
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(shortlistKeys)); } catch (e) { /* private mode */ }
  }

  function selectedRows(tableState) {
    const data = tableState.data || [];
    return (tableState.selected || []).map((i) => data[i]).filter(Boolean);
  }

  function updateShortlist(tableState) {
    const rows = selectedRows(tableState);
    const keys = rows.map((r) => r.row_key).sort();
    const changed = keys.join('\n') !== shortlistKeys.join('\n');
    shortlistKeys = keys;
    $('agt-shortlist').hidden = keys.length === 0 && !state.shortlistOnly;
    $('agt-shortlist-count').textContent = keys.length + (keys.length === 1 ? ' parameter' : ' parameters') +
      ' in ' + new Set(rows.map((r) => r.id)).size + ' datasets shortlisted';
    if (changed) {
      storeShortlist();
      if (state.shortlistOnly) apply();
    }
  }

  function restoreShortlist() {
    const stored = readStoredShortlist();
    if (!stored.length) return;
    const data = Reactable.getState(TABLE).data || [];
    const wanted = new Set(stored);
    const indices = [];
    data.forEach((row, i) => { if (wanted.has(row.row_key)) indices.push(i); });
    // selection helpers exist only on the table instance, not on the Reactable API
    if (indices.length) Reactable.getInstance(TABLE).setRowsSelected(indices);
  }

  function csvOf(rows, columns) {
    const cell = (v) => {
      if (v == null) return '';
      const s = String(v);
      return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
    };
    return [columns.join(',')].concat(rows.map((r) => columns.map((c) => cell(r[c])).join(','))).join('\n') + '\n';
  }

  function downloadShortlist() {
    const rows = selectedRows(Reactable.getState(TABLE));
    const blob = new Blob([csvOf(rows, cfg.exportColumns)], { type: 'text/csv;charset=utf-8' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'awesome-geodata-table_shortlist_' + new Date().toISOString().slice(0, 10) + '.csv';
    document.body.appendChild(a);
    a.click();
    setTimeout(() => { URL.revokeObjectURL(a.href); a.remove(); }, 0);
  }

  // BibTeX via DOI content negotiation; datasets without DOI (or offline) get a @misc entry
  function fallbackBib(row) {
    const key = row.id.replace(/[^a-z0-9]/gi, '');
    const year = row.published || '';
    return '@misc{' + key + ',\n  title = {' + row.name + '},\n' +
      (row.publisher ? '  author = {{' + row.publisher + '}},\n' : '') +
      (year ? '  year = {' + year + '},\n' : '') +
      '  howpublished = {\\url{' + row.download_url + '}},\n' +
      (row.doi ? '  doi = {' + row.doi + '},\n' : '') + '}';
  }

  async function bibOf(row) {
    if (!row.doi) return fallbackBib(row);
    try {
      const res = await fetch('https://doi.org/' + encodeURI(row.doi), { headers: { Accept: 'application/x-bibtex' } });
      if (!res.ok) throw new Error(res.status);
      const text = (await res.text()).trim();
      return text.startsWith('@') ? text : fallbackBib(row);
    } catch (e) {
      return fallbackBib(row);
    }
  }

  async function copyBibtex() {
    const status = $('agt-shortlist-status');
    const byDataset = new Map();
    selectedRows(Reactable.getState(TABLE)).forEach((r) => { if (!byDataset.has(r.id)) byDataset.set(r.id, r); });
    status.textContent = 'Fetching ' + byDataset.size + ' citations …';
    const entries = await Promise.all(Array.from(byDataset.values()).map(bibOf));
    const bib = entries.join('\n\n') + '\n';
    copyText(bib).then(
      () => { status.textContent = byDataset.size + ' BibTeX entries copied'; },
      () => { status.textContent = 'Copy failed – clipboard not available'; }
    );
    return bib;
  }
  // exposed for tests
  window.AGT_copyBibtex = copyBibtex;

  // ---- result counter ---------------------------------------------------------
  // sortedData holds group rows (with _subRows) while grouped by dataset
  const leafRows = (rows) => rows.flatMap((r) => r._subRows ? leafRows(r._subRows) : [r]);

  function updateCount(tableState) {
    const rows = leafRows(tableState.sortedData || []);
    const datasets = new Set(rows.map((r) => r.id)).size;
    const total = tableState.data ? tableState.data.length : rows.length;
    $('agt-count').innerHTML = '<strong>' + rows.length + '</strong> of ' + total +
      ' parameters in <strong>' + datasets + '</strong> datasets';
  }

  // ---- wiring -----------------------------------------------------------------
  function init() {
    multiSelects.forEach((el) => {
      if (window.TomSelect) {
        new TomSelect(el, {
          plugins: ['remove_button'],
          maxOptions: null,
          hidePlaceholder: true,
          onChange: () => { readControls(); apply(); }
        });
      } else {
        el.addEventListener('change', () => { readControls(); apply(); });
      }
    });

    let searchTimer;
    $('agt-search').addEventListener('input', () => {
      clearTimeout(searchTimer);
      searchTimer = setTimeout(() => { readControls(); apply(); }, 100);
    });
    // keep the handles from crossing and update the label while dragging
    ['agt-f-from', 'agt-f-to'].forEach((id) => $(id).addEventListener('input', () => {
      const from = $('agt-f-from'), to = $('agt-f-to');
      if (+from.value > +to.value) {
        if (id === 'agt-f-from') from.value = to.value; else to.value = from.value;
      }
      updatePeriodSlider();
    }));
    $('agt-f-spatial').addEventListener('input', () => {
      $('agt-f-spatial-out').textContent = fmtMetres(sliderToMetres(+$('agt-f-spatial').value));
    });
    ['agt-f-spatial', 'agt-f-temporal', 'agt-f-static', 'agt-f-from', 'agt-f-to', 'agt-f-undated', 'agt-f-lat', 'agt-f-lon']
      .forEach((id) => $(id).addEventListener('change', () => { readControls(); apply(); }));

    presetButtons.forEach((b) => b.addEventListener('click', () => applyPreset(b)));
    $('agt-f-map-toggle').addEventListener('click', toggleStudyMap);
    $('agt-f-area-clear').addEventListener('click', () => setStudyPoint(null, null));

    $('agt-reset').addEventListener('click', reset);
    $('agt-group').addEventListener('click', () => {
      state.grouped = !state.grouped;
      $('agt-group').setAttribute('aria-pressed', String(state.grouped));
      apply();
    });
    $('agt-expand').addEventListener('click', () => Reactable.toggleAllRowsExpanded(TABLE));
    $('agt-download').addEventListener('click', () => {
      const date = new Date().toISOString().slice(0, 10);
      Reactable.downloadDataCSV(TABLE, 'awesome-geodata-table_' + date + '.csv', { columnIds: cfg.exportColumns });
    });
    $('agt-link').addEventListener('click', () => {
      const btn = $('agt-link');
      copyText(location.href).then(() => flash(btn, 'Copied ✓', 'Copy link'), () => flash(btn, 'Copy failed', 'Copy link'));
    });

    $('agt-shortlist-show').addEventListener('click', () => {
      state.shortlistOnly = !state.shortlistOnly;
      $('agt-shortlist-show').setAttribute('aria-pressed', String(state.shortlistOnly));
      apply();
    });
    $('agt-shortlist-csv').addEventListener('click', downloadShortlist);
    $('agt-shortlist-bib').addEventListener('click', copyBibtex);
    $('agt-shortlist-clear').addEventListener('click', () => {
      Reactable.getInstance(TABLE).toggleAllRowsSelected(false);
      state.shortlistOnly = false;
      $('agt-shortlist-show').setAttribute('aria-pressed', 'false');
      apply();
    });

    const panel = $('agt-filters');
    const toggle = $('agt-toggle-filters');
    const setPanel = (open) => { panel.hidden = !open; toggle.setAttribute('aria-expanded', String(open)); };
    toggle.addEventListener('click', () => setPanel(panel.hidden));
    setPanel(window.matchMedia('(min-width: 768px)').matches || location.search.length > 1);

    const tableEl = $(TABLE);
    tableEl.addEventListener('click', onSnippetClick);
    new MutationObserver(() => initFootprints(tableEl)).observe(tableEl, { childList: true, subtree: true });

    Reactable.onStateChange(TABLE, (s) => { updateCount(s); updateShortlist(s); });
    readUrl();
    writeControls();
    apply();
    restoreShortlist();
  }

  // the widget is rendered asynchronously; wait for its instance
  const tableReady = () => {
    try { return Boolean(window.Reactable && Reactable.getInstance(TABLE)); } catch (e) { return false; }
  };
  (function waitForTable(tries) {
    if (tableReady()) init();
    else if (tries > 0) setTimeout(() => waitForTable(tries - 1), 50);
    else console.error('Awesome Geodata Table: table "' + TABLE + '" not found');
  })(200);
})();
