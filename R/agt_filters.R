# Filter panel above the table. Every control carries `data-filter` (the column
# it filters) and is wired up by assets/agt.js.

present_in_order <- function(levels, values) {
  levels[levels %in% values]
}

#' Multi-select filter; `labels` (named by value) and `groups` (named by value,
#' rendered as <optgroup>) are optional
multi_select <- function(column, label, choices, labels = NULL, groups = NULL) {
  input_id <- paste0("agt-f-", column)
  option <- function(x) htmltools::tags$option(value = x, if (is.null(labels)) x else labels[[x]])
  options <- if (is.null(groups)) {
    purrr::map(choices, option)
  } else {
    purrr::map(unique(groups[choices]), \(g) {
      htmltools::tags$optgroup(label = g, purrr::map(choices[groups[choices] == g], option))
    })
  }
  htmltools::div(
    class = "agt-field",
    htmltools::tags$label(`for` = input_id, label),
    htmltools::tags$select(
      id = input_id, multiple = NA, `data-filter` = column, `data-kind` = "multi",
      `aria-label` = label, placeholder = "any", options
    )
  )
}

#' Build the filter panel
#'
#' @param data Output of `read_metadata()`.
#' @param schema Output of `read_schema()`.
agt_filters <- function(data, schema, dictionary = read_dictionary()) {
  all_tags <- sort(unique(unlist(purrr::map(data$tags, split_tags))))
  temporal <- vocab_labels(schema, "temporal_resolution")
  temporal <- temporal[names(temporal) != "static"]
  spatial_range <- range(data$res_spatial_finest_m, na.rm = TRUE)
  year_range <- range(c(data$coverage_start_year, data$coverage_end_year), na.rm = TRUE)

  config <- list(
    tableId = AGT_TABLE_ID,
    exportColumns = agt_export_columns(schema),
    spatialMin = max(1, spatial_range[1]),
    spatialMax = spatial_range[2],
    yearMin = year_range[1],
    yearMax = year_range[2],
    dictionary = purrr::map(dictionary_terms(dictionary), I)  # I(): keep 1-term concepts as arrays
  )

  variables <- schema$vocabularies$variable
  variable_keys <- present_in_order(vocab_keys(schema, "variable"), data$variable)
  variable_groups <- purrr::set_names(purrr::map_chr(variables, "group"), vocab_keys(schema, "variable"))

  htmltools::tagList(
    htmltools::tags$script(
      id = "agt-config", type = "application/json",
      htmltools::HTML(jsonlite::toJSON(config, auto_unbox = TRUE))
    ),
    htmltools::div(
      class = "agt-presets", role = "group", `aria-label` = "Quick start searches",
      htmltools::span(class = "agt-presets-label", "Quick start:"),
      purrr::map(schema$presets, \(p) htmltools::tags$button(
        type = "button", class = "agt-preset", `data-query` = p$query, title = p$description,
        `aria-pressed` = "false", p$label
      ))
    ),
    htmltools::div(
      class = "agt-toolbar",
      htmltools::div(
        class = "agt-search",
        htmltools::tags$input(
          id = "agt-search", type = "search", placeholder = "Search parameters, datasets, tags, publishers …",
          `aria-label` = "Search", autocomplete = "off"
        )
      ),
      htmltools::div(id = "agt-count", class = "agt-count", role = "status", `aria-live` = "polite"),
      htmltools::div(
        class = "agt-actions",
        htmltools::tags$button(id = "agt-toggle-filters", type = "button", class = "agt-btn", `aria-expanded` = "true", `aria-controls` = "agt-filters", "Filters"),
        htmltools::tags$button(id = "agt-group", type = "button", class = "agt-btn", `aria-pressed` = "false", "Group by dataset"),
        htmltools::tags$button(id = "agt-expand", type = "button", class = "agt-btn", "Expand details"),
        htmltools::tags$button(id = "agt-reset", type = "button", class = "agt-btn", "Reset"),
        htmltools::tags$button(id = "agt-link", type = "button", class = "agt-btn", title = "Copy a link to the current search", "Copy link"),
        htmltools::tags$button(id = "agt-download", type = "button", class = "agt-btn agt-btn-primary", "Download CSV")
      )
    ),
    htmltools::div(
      id = "agt-filters", class = "agt-filters",
      multi_select("name", "Dataset", sort(unique(data$name))),
      multi_select("variable", "Variable", variable_keys, labels = vocab_labels(schema, "variable"), groups = variable_groups),
      multi_select("parameter", "Parameter", sort(unique(data$parameter))),
      multi_select("tags", "Tags", all_tags),
      multi_select("domain", "Domain", present_in_order(vocab_keys(schema, "domain"), data$domain)),
      multi_select("coverage_spatial", "Spatial coverage", present_in_order(vocab_keys(schema, "coverage_spatial"), data$coverage_spatial)),
      multi_select("access", "Access", present_in_order(vocab_keys(schema, "access"), data$access)),
      multi_select("data_type", "Data type", present_in_order(vocab_keys(schema, "data_type"), data$data_type)),
      multi_select("license_class", "License", present_in_order(vocab_keys(schema, "license_class"), data$license_class)),
      htmltools::div(
        class = "agt-field agt-field-area",
        htmltools::tags$label(`for` = "agt-f-lat", "Study area (point)"),
        htmltools::div(
          class = "agt-area",
          htmltools::tags$input(id = "agt-f-lat", type = "number", step = "any", min = -90, max = 90, placeholder = "lat", `aria-label` = "Latitude"),
          htmltools::tags$input(id = "agt-f-lon", type = "number", step = "any", min = -180, max = 180, placeholder = "lon", `aria-label` = "Longitude"),
          htmltools::tags$button(id = "agt-f-map-toggle", type = "button", class = "agt-btn", `aria-expanded` = "false", `aria-controls` = "agt-map", "Map"),
          htmltools::tags$button(id = "agt-f-area-clear", type = "button", class = "agt-btn", `aria-label` = "Clear study area", "×")
        ),
        htmltools::div(class = "agt-hint", "Keeps datasets whose extent covers the point")
      ),
      htmltools::div(
        class = "agt-field",
        htmltools::tags$label(`for` = "agt-f-spatial", "Spatial res. at least", htmltools::tags$output(id = "agt-f-spatial-out", `for` = "agt-f-spatial", "any")),
        htmltools::tags$input(
          id = "agt-f-spatial", type = "range", min = 0, max = 1000, value = 1000, step = 1,
          `data-filter` = "res_spatial_finest_m", `data-kind` = "spatial",
          `aria-label` = "Coarsest acceptable spatial resolution"
        )
      ),
      htmltools::div(
        class = "agt-field",
        htmltools::tags$label(`for` = "agt-f-temporal", "Temporal res. at least"),
        htmltools::tags$select(
          id = "agt-f-temporal", `data-filter` = "res_temporal_finest_rank", `data-kind` = "temporal",
          htmltools::tags$option(value = "", "any"),
          purrr::imap(unname(temporal), \(label, i) htmltools::tags$option(value = i, label))
        ),
        htmltools::tags$label(
          class = "agt-check",
          htmltools::tags$input(id = "agt-f-static", type = "checkbox", checked = NA),
          "include static data"
        )
      ),
      htmltools::div(
        class = "agt-field",
        htmltools::tags$label(`for` = "agt-f-from", "Covers period", htmltools::tags$output(id = "agt-f-period-out", "any")),
        # two stacked range inputs form one slider with two handles
        htmltools::div(
          class = "agt-dual-range",
          htmltools::div(class = "agt-dual-range-fill", id = "agt-f-period-fill"),
          htmltools::tags$input(
            id = "agt-f-from", type = "range", min = year_range[1], max = year_range[2],
            value = year_range[1], step = 1, `aria-label` = "From year", `data-kind` = "period"
          ),
          htmltools::tags$input(
            id = "agt-f-to", type = "range", min = year_range[1], max = year_range[2],
            value = year_range[2], step = 1, `aria-label` = "To year", `data-kind` = "period"
          )
        ),
        htmltools::tags$label(
          class = "agt-check",
          htmltools::tags$input(id = "agt-f-undated", type = "checkbox", checked = NA),
          "include undated data"
        )
      ),
      htmltools::div(id = "agt-map", class = "agt-map", hidden = NA, `aria-label` = "Click to set the study area point")
    ),
    htmltools::div(
      id = "agt-shortlist", class = "agt-shortlist", hidden = NA, role = "region", `aria-label` = "Shortlist",
      htmltools::span(id = "agt-shortlist-count", class = "agt-shortlist-count"),
      htmltools::tags$button(id = "agt-shortlist-show", type = "button", class = "agt-btn", `aria-pressed` = "false", "Show only shortlist"),
      htmltools::tags$button(id = "agt-shortlist-csv", type = "button", class = "agt-btn", "Download shortlist CSV"),
      htmltools::tags$button(id = "agt-shortlist-bib", type = "button", class = "agt-btn", "Copy BibTeX"),
      htmltools::tags$button(id = "agt-shortlist-clear", type = "button", class = "agt-btn", "Clear"),
      htmltools::span(id = "agt-shortlist-status", class = "agt-hint", role = "status", `aria-live` = "polite")
    )
  )
}
