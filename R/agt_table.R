# Interactive table of the Awesome Geodata Table.
#
# All filtering happens client-side: the filter panel (agt_filters.R +
# assets/agt.js) calls Reactable.setFilter()/setSearch() with plain values and
# the filter methods below interpret them. An empty value always means
# "filter off", so clearing an input restores every row.

AGT_TABLE_ID <- "agt"

# helper prepended to every JS render function that returns HTML
JS_ESCAPE <- "const esc = (s) => String(s == null ? '' : s).replace(/[&<>\"']/g, (c) => ({'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;',\"'\":'&#39;'}[c]));"

js_fn <- function(args, body, escape = FALSE) {
  reactable::JS(sprintf("function(%s) { %s %s }", args, if (escape) JS_ESCAPE else "", body))
}

# Filter methods ----------------------------------------------------------------

# value is one of the selected values
js_filter_in <- js_fn("rows, columnId, values", "
  if (!Array.isArray(values) || values.length === 0) return rows;
  const set = new Set(values);
  return rows.filter((row) => set.has(row.values[columnId]));
")

# at least one of the selected tags is present
js_filter_tags <- js_fn("rows, columnId, values", "
  if (!Array.isArray(values) || values.length === 0) return rows;
  const set = new Set(values);
  return rows.filter((row) => String(row.values[columnId] || '').split('; ').some((t) => set.has(t)));
")

# finest resolution at least as fine as the threshold; unknown passes
js_filter_max <- js_fn("rows, columnId, max", "
  if (max == null) return rows;
  return rows.filter((row) => row.values[columnId] == null || row.values[columnId] <= max);
")

# finest temporal resolution class at least as fine as `max`; static rows are
# kept unless `includeStatic` is false; unknown passes
js_filter_temporal <- function(static_rank) {
  js_fn("rows, columnId, f", sprintf("
    if (!f) return rows;
    return rows.filter((row) => {
      const v = row.values[columnId];
      if (v == null) return true;
      if (v === %d) return f.includeStatic !== false;
      return f.max == null || v <= f.max;
    });
  ", static_rank))
}

# coverage period overlaps [from, to]; undated rows pass unless excluded
js_filter_period <- js_fn("rows, columnId, f", "
  if (!f || (f.from == null && f.to == null)) return rows;
  const from = f.from == null ? -Infinity : f.from;
  const to = f.to == null ? Infinity : f.to;
  return rows.filter((row) => {
    const s = row.values.coverage_start_year, e = row.values.coverage_end_year;
    if (s == null && e == null) return f.includeUndated !== false;
    return (s == null ? -Infinity : s) <= to && (e == null ? Infinity : e) >= from;
  });
")

# every search word must occur in the pre-built search text
js_search <- js_fn("rows, columnIds, query", "
  const words = String(query || '').toLowerCase().split(/\\s+/).filter(Boolean);
  if (words.length === 0) return rows;
  return rows.filter((row) => {
    const text = row.values.search_text || '';
    return words.every((w) => text.includes(w));
  });
")

# Cell renderers ----------------------------------------------------------------

js_cell_spatial <- js_fn("cellInfo", "
  const fmt = (m) => m == null ? null : (m >= 1000 ? (+(m / 1000).toPrecision(3)) + ' km' : (+m.toPrecision(3)) + ' m');
  const a = fmt(cellInfo.value), b = fmt(cellInfo.row.res_spatial_coarsest_m);
  if (a == null && b == null) return '<span class=\"agt-na\">–</span>';
  return esc(a === b || b == null ? a : (a == null ? b : a + ' – ' + b));
", escape = TRUE)

js_cell_temporal <- function(labels) {
  js_fn("cellInfo", sprintf("
    const labels = %s;
    const a = labels[cellInfo.value - 1], b = labels[cellInfo.row.res_temporal_coarsest_rank - 1];
    if (a == null && b == null) return '<span class=\"agt-na\">–</span>';
    return esc(a === b || b == null ? a : (a == null ? b : a + ' – ' + b));
  ", jsonlite::toJSON(unname(labels))), escape = TRUE)
}

js_cell_period <- js_fn("cellInfo", "
  const s = cellInfo.value, e = cellInfo.row.coverage_end;
  if (s == null && e == null) return '<span class=\"agt-na\">–</span>';
  return esc((s == null ? '?' : s) + '–' + (e == null ? '?' : e));
", escape = TRUE)

js_cell_pill <- function(levels, attribute) {
  js_fn("cellInfo", sprintf("
    if (cellInfo.value == null) return '';
    const i = %s.indexOf(cellInfo.value) + 1;
    return '<span class=\"agt-pill\" data-%s=\"' + i + '\">' + esc(cellInfo.value) + '</span>';
  ", jsonlite::toJSON(unname(levels)), attribute), escape = TRUE)
}

js_cell_tags <- js_fn("cellInfo", "
  if (cellInfo.value == null) return '';
  const tags = String(cellInfo.value).split('; ');
  return '<span class=\"agt-tags\" title=\"' + esc(tags.join(', ')) + '\">' +
    tags.map((t) => '<span class=\"agt-tag\">' + esc(t) + '</span>').join('') + '</span>';
", escape = TRUE)

js_cell_links <- js_fn("cellInfo", "
  const r = cellInfo.row, out = [];
  if (r.download_url) out.push('<a class=\"agt-link\" href=\"' + esc(r.download_url) + '\" target=\"_blank\" rel=\"noopener\" title=\"Download / access\" aria-label=\"Download\">&#x2913;</a>');
  if (r.doi) out.push('<a class=\"agt-link\" href=\"https://doi.org/' + esc(r.doi) + '\" target=\"_blank\" rel=\"noopener\" title=\"DOI: ' + esc(r.doi) + '\">DOI</a>');
  else if (r.doc_url) out.push('<a class=\"agt-link\" href=\"' + esc(r.doc_url) + '\" target=\"_blank\" rel=\"noopener\" title=\"Documentation\">Doc</a>');
  return out.join(' ');
", escape = TRUE)

# Row details: every remaining dataset field as a compact definition list
js_details <- function(fields) {
  js_fn("rowInfo", sprintf("
    const fields = %s;
    const r = rowInfo.values;
    const link = (u) => '<a href=\"' + esc(u) + '\" target=\"_blank\" rel=\"noopener\">' + esc(u) + '</a>';
    const items = fields.map((f) => {
      let v = r[f.id];
      if (v == null || v === '') return '';
      if (f.type === 'url') v = link(v);
      else if (f.id === 'doi') v = link('https://doi.org/' + v);
      else if (f.type === 'tags') v = String(v).split('; ').map((t) => '<span class=\"agt-tag\">' + esc(t) + '</span>').join('');
      else v = esc(v);
      return '<div class=\"agt-detail\"><dt>' + esc(f.label) + '</dt><dd>' + v + '</dd></div>';
    }).join('');
    return '<dl class=\"agt-details\">' + items + '</dl>';
  ", jsonlite::toJSON(fields, auto_unbox = TRUE)), escape = TRUE)
}

# Table -------------------------------------------------------------------------

#' Columns that are exported by the CSV download (raw metadata, no helpers)
agt_export_columns <- function(schema) {
  c("id", "name", "parameter", "unit", setdiff(names(schema$datasets), c("id", "name")))
}

#' Build the interactive reactable widget
#'
#' @param data Output of `read_metadata()`.
#' @param schema Output of `read_schema()`.
agt_table <- function(data, schema) {
  temporal_labels <- vocab_labels(schema, "temporal_resolution")
  domains <- vocab_keys(schema, "domain")
  access_levels <- vocab_keys(schema, "access")

  data <- data |>
    dplyr::mutate(
      search_text = stringr::str_to_lower(paste(
        name, parameter, tags, domain, publisher, coverage_spatial, comment, id,
        sep = " | "
      )),
      links = download_url
    )

  detail_fields <- c(
    "tags", "publisher", "data_type", "format", "crs", "res_spatial_note",
    "temporal_type", "vertical", "maintained", "latency", "published", "method",
    "processing_level", "access_method", "license", "download_url", "doc_url",
    "doi", "quality_notes", "comment"
  )
  details <- purrr::map(detail_fields, \(f) list(
    id = f, label = schema$datasets[[f]]$label, type = schema$datasets[[f]]$type
  ))

  visible <- list(
    parameter = reactable::colDef(
      name = "Parameter", sticky = "left", minWidth = 190,
      filterMethod = js_filter_in,
      # shown on dataset rows when grouped
      aggregate = "count", aggregated = js_fn("cellInfo", "return cellInfo.value + (cellInfo.value === 1 ? ' parameter' : ' parameters');"),
      style = list(fontWeight = 600)
    ),
    unit = reactable::colDef(name = "Unit", minWidth = 80, maxWidth = 120),
    name = reactable::colDef(
      name = "Dataset", minWidth = 260, filterMethod = js_filter_in,
      cell = js_fn("cellInfo", "return '<span title=\"' + esc(cellInfo.value) + '\">' + esc(cellInfo.value) + '</span>';", escape = TRUE),
      html = TRUE
    ),
    domain = reactable::colDef(
      name = "Domain", minWidth = 150, filterMethod = js_filter_in,
      cell = js_cell_pill(domains, "domain"), html = TRUE, aggregate = "unique"
    ),
    res_spatial_finest_m = reactable::colDef(
      name = "Spatial res.", minWidth = 110, filterMethod = js_filter_max,
      cell = js_cell_spatial, html = TRUE, sortNALast = TRUE
    ),
    res_temporal_finest_rank = reactable::colDef(
      name = "Temporal res.", minWidth = 130,
      filterMethod = js_filter_temporal(match("static", names(temporal_labels))),
      cell = js_cell_temporal(temporal_labels), html = TRUE, sortNALast = TRUE
    ),
    coverage_start_year = reactable::colDef(
      name = "Period", minWidth = 100, filterMethod = js_filter_period,
      cell = js_cell_period, html = TRUE, sortNALast = TRUE
    ),
    coverage_spatial = reactable::colDef(name = "Coverage", minWidth = 90, filterMethod = js_filter_in, aggregate = "unique"),
    access = reactable::colDef(
      name = "Access", minWidth = 100, filterMethod = js_filter_in,
      cell = js_cell_pill(access_levels, "access"), html = TRUE, aggregate = "unique"
    ),
    tags = reactable::colDef(
      name = "Tags", minWidth = 220, filterMethod = js_filter_tags,
      cell = js_cell_tags, html = TRUE, sortable = FALSE
    ),
    links = reactable::colDef(
      name = "Links", minWidth = 80, maxWidth = 90, sortable = FALSE,
      cell = js_cell_links, html = TRUE
    )
  )

  hidden_cols <- setdiff(names(data), names(visible))
  hidden <- purrr::map(
    purrr::set_names(hidden_cols),
    \(col) reactable::colDef(
      show = FALSE,
      searchable = col == "search_text",
      filterMethod = if (col == "data_type") js_filter_in
    )
  )

  # Reactable.setFilter() only works on filterable columns; their built-in
  # filter inputs are hidden via CSS because the filter panel drives them
  columns <- purrr::map(c(visible, hidden), \(col) {
    if (!is.null(col$filterMethod)) col$filterable <- TRUE
    col
  })

  data <- data |> dplyr::select(dplyr::all_of(c(names(visible), hidden_cols)))

  reactable::reactable(
    data,
    elementId = AGT_TABLE_ID,
    columns = columns,
    details = reactable::colDef(details = js_details(details), html = TRUE, width = 32),
    # built-in search box is hidden via CSS, the filter panel calls setSearch()
    searchable = TRUE,
    searchMethod = js_search,
    sortable = TRUE,
    resizable = TRUE,
    defaultSorted = c("name", "parameter"),
    defaultColDef = reactable::colDef(
      align = "left", vAlign = "center", headerVAlign = "bottom", minWidth = 70
    ),
    pagination = TRUE,
    defaultPageSize = 50,
    showPageSizeOptions = TRUE,
    pageSizeOptions = c(25, 50, 100, 250, 1000),
    paginationType = "jump",
    showPageInfo = TRUE,
    compact = TRUE,
    wrap = FALSE,
    highlight = TRUE,
    striped = FALSE,
    borderless = FALSE,
    outlined = TRUE,
    language = reactable::reactableLang(
      noData = "No matching parameters – try removing a filter.",
      pageInfo = "{rowStart}–{rowEnd} of {rows} rows"
    ),
    theme = agt_theme(),
    class = "agt-table"
  )
}

#' Compact theme driven by CSS variables (light/dark aware, see assets/agt.css)
agt_theme <- function() {
  reactable::reactableTheme(
    color = "var(--agt-fg)",
    backgroundColor = "var(--agt-bg)",
    borderColor = "var(--agt-border)",
    stripedColor = "var(--agt-stripe)",
    highlightColor = "var(--agt-hover)",
    cellPadding = "4px 8px",
    style = list(fontSize = "13px"),
    headerStyle = list(
      fontSize = "12px", fontWeight = 600, textTransform = "uppercase",
      letterSpacing = "0.03em", color = "var(--agt-muted)",
      background = "var(--agt-bg)", borderBottomWidth = "2px"
    ),
    rowSelectedStyle = list(backgroundColor = "var(--agt-hover)"),
    paginationStyle = list(fontSize = "13px", color = "var(--agt-muted)"),
    pageButtonStyle = list(fontSize = "13px"),
    inputStyle = list(backgroundColor = "var(--agt-bg)", color = "var(--agt-fg)")
  )
}
