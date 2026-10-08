// Filter panel controller for the Awesome Geodata Table.
//
// All filter state lives in `state`. Every change calls apply(), which pushes
// the *complete* state to the table: empty inputs are sent as `undefined`
// (filter off), so clearing an input always brings every row back.
(function () {
  'use strict';

  const cfg = JSON.parse(document.getElementById('agt-config').textContent);
  const TABLE = cfg.tableId;
  const $ = (id) => document.getElementById(id);
  const multiSelects = Array.from(document.querySelectorAll('select[data-kind="multi"]'));
  const SLIDER_MAX = 1000;
  const logMin = Math.log10(cfg.spatialMin);
  const logMax = Math.log10(cfg.spatialMax);

  const state = {
    search: '',
    multi: {},          // column -> array of selected values
    spatial: null,      // metres; null = off
    temporal: null,     // rank; null = off
    includeStatic: true,
    from: null,
    to: null,
    includeUndated: true,
    grouped: false
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
  const empty = (v) => v == null || (Array.isArray(v) && v.length === 0);

  function selectValues(el) {
    if (el.tomselect) return el.tomselect.getValue();
    return Array.from(el.selectedOptions).map((o) => o.value);
  }
  function setSelectValues(el, values) {
    if (el.tomselect) { el.tomselect.setValue(values, true); return; }
    Array.from(el.options).forEach((o) => { o.selected = values.includes(o.value); });
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
  }

  // ---- state -> controls (used for URL restore and reset) --------------------
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
    $('agt-group').setAttribute('aria-pressed', String(state.grouped));
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
    writeUrl();
  }

  function markActiveFields() {
    multiSelects.forEach((el) => el.closest('.agt-field').classList.toggle('is-active', !empty(state.multi[el.dataset.filter])));
    $('agt-f-spatial').closest('.agt-field').classList.toggle('is-active', state.spatial != null);
    $('agt-f-temporal').closest('.agt-field').classList.toggle('is-active', state.temporal != null || !state.includeStatic);
    $('agt-f-from').closest('.agt-field').classList.toggle('is-active', state.from != null || state.to != null);
  }

  // ---- URL <-> state ----------------------------------------------------------
  function writeUrl() {
    const p = new URLSearchParams();
    if (state.search) p.set('q', state.search);
    Object.entries(state.multi).forEach(([c, v]) => { if (!empty(v)) p.set(c, v.join('|')); });
    if (state.spatial != null) p.set('spatial', state.spatial);
    if (state.temporal != null) p.set('temporal', state.temporal);
    if (!state.includeStatic) p.set('static', '0');
    if (state.from != null) p.set('from', state.from);
    if (state.to != null) p.set('to', state.to);
    if (!state.includeUndated) p.set('undated', '0');
    if (state.grouped) p.set('group', '1');
    const qs = p.toString();
    history.replaceState(null, '', qs ? '?' + qs : location.pathname + location.hash);
  }

  function readUrl() {
    const p = new URLSearchParams(location.search);
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
    state.grouped = p.get('group') === '1';
  }

  function reset() {
    state.search = '';
    multiSelects.forEach((el) => { state.multi[el.dataset.filter] = []; });
    Object.assign(state, { spatial: null, temporal: null, includeStatic: true, from: null, to: null, includeUndated: true });
    writeControls();
    apply();
  }

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
    ['agt-f-spatial', 'agt-f-temporal', 'agt-f-static', 'agt-f-from', 'agt-f-to', 'agt-f-undated']
      .forEach((id) => $(id).addEventListener('change', () => { readControls(); apply(); }));

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
      const done = (text) => { btn.textContent = text; setTimeout(() => { btn.textContent = 'Copy link'; }, 1500); };
      if (navigator.clipboard) navigator.clipboard.writeText(location.href).then(() => done('Copied ✓'), () => done('Copy failed'));
      else done('Copy failed');
    });

    const panel = $('agt-filters');
    const toggle = $('agt-toggle-filters');
    const setPanel = (open) => { panel.hidden = !open; toggle.setAttribute('aria-expanded', String(open)); };
    toggle.addEventListener('click', () => setPanel(panel.hidden));
    setPanel(window.matchMedia('(min-width: 768px)').matches || location.search.length > 1);

    Reactable.onStateChange(TABLE, updateCount);
    readUrl();
    writeControls();
    apply();
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
