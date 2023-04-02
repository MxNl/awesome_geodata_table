columndef_list <- function() {
  list(
    `Dataset name` = colDef(
      name = "Dataset name",
      align = "left",
      sticky = "left",
      minWidth = 200
    ),
    Parameter = colDef(
      name = "Parameter",
      align = "left",
      sticky = "left",
      minWidth = 230
    ),
    Domain = colDef(
      name = "Domain",
      align = "left",
      minWidth = 200
    ),
    Tags = colDef(
      vAlign = "center",
      cell = function(value, index, name) {
        render_reactable_cell_with_tippy(text = value, tooltip = value)
      }
    ),
    Unit = colDef(cell = function(value) {
      # Omit inline = TRUE to render math in display mode
      katexR::katex(value, inline = TRUE)
    }),
    min = colDef(
      name = "min",
      # cell = reactablefmtr::color_tiles(
      #   data = table_data,
      #   colors = viridis::mako(n = 17, begin = 0, end = 0.7, direction = -1), #MetBrewer::met.brewer("VanGogh3", n = 5, direction = -1),
      #   opacity = 0.5,
      #   bold_text = TRUE,
      #   box_shadow = TRUE
      # ),
      style = function(value) {
        value_levels <- c(table_data$min, table_data$max) %>%
          unique() %>%
          levels()
        n_values <- value_levels %>%
          length()
        value_norm <- 1 / (n_values - 1) * (which(value == value_levels) - 1)
        color <- good_color_bymock(value_norm)
        list(background = color)
      }
    ),
    max = colDef(
      name = "max",
      style = function(value) {
        value_levels <- c(table_data$min, table_data$max) %>%
          unique() %>%
          levels()
        n_values <- value_levels %>%
          length()
        value_norm <- 1 / (n_values - 1) * (which(value == value_levels) - 1)
        color <- good_color_bymock(value_norm)
        list(background = color)
      }
    ),
    start = colDef(
      format = colFormat(date = TRUE, locales = "en-GB")
    ),
    end = colDef(
      format = colFormat(date = TRUE, locales = "en-GB")
    ),
    `Version updates` = colDef(
      name = "Version updates",
      cell = function(value) {
        # Render as an X mark or check mark
        if (value == "no") {
          render_reactable_cell_with_tippy(text = "\u274c", tooltip = value)
        } else if (value == "yes") {
          render_reactable_cell_with_tippy(text = "\u2714\ufe0f", tooltip = value)
        } else if (is.na(value)) {
          "unknown"
        } else value
      }
    ),
    Download = colDef(
      name = "Download",
      cell = function(value) {
        if (stringr::str_detect(value, "http") | is.na(value)) {
          htmltools::tags$a(href = value, target = "_blank", "link")
        } else {
          "no link yet"
        }
      }
    ),
    Literature = colDef(
      name = "Literature",
      cell = function(value) {
        if (stringr::str_detect(value, "http") | is.na(value)) {
          htmltools::tags$a(href = value, target = "_blank", "link")
        } else {
          "no link yet"
        }
      }
    ),
    Publisher = colDef(
      vAlign = "center",
      cell = function(value, index, name) {
        render_reactable_cell_with_tippy(text = value, tooltip = value)
      }
    ),
    License = colDef(
      minWidth = 160
    ),
    Comment = colDef(
      name = "Comment",
      cell = function(value, index, name) {
        render_reactable_cell_with_tippy(text = value, tooltip = value)
      }
    )
  )
}