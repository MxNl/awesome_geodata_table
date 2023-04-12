columndef_list <- function(table_data, columns_to_show) {
  list(
    `Dataset name` = colDef(
      name = "Dataset name",
      align = "left",
      sticky = "left",
      minWidth = 200,
      show = columns_to_show$`Dataset name`
    ),
    Parameter = colDef(
      name = "Parameter",
      align = "left",
      sticky = "left",
      minWidth = 230,
      show = columns_to_show$Parameter
    ),
    Tags = colDef(
      vAlign = "center",
      cell = function(value, index, name) {
        render_reactable_cell_with_tippy(text = value, tooltip = value)
      },
      show = columns_to_show$Tags
    ),
    Domain = colDef(
      name = "Domain",
      align = "left",
      minWidth = 200,
      cell = pill_buttons(
        data = table_data,
        color_ref = "domain_icon_colors",
        show = columns_to_show$Domain
      )
    ),
    Unit = colDef(cell = function(value) {
      # Omit inline = TRUE to render math in display mode
      katexR::katex(value, inline = TRUE)
    },
                  show = columns_to_show$Unit
    ),
    min = colDef(
      show = columns_to_show$min,
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
      show = columns_to_show$max,
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
    `Upload delay` = colDef(
      show = columns_to_show$`Upload delay`,
    ),
    `min [m]` = colDef(
      show = columns_to_show$`min [m]`,
    ),
    `max [m]` = colDef(
      show = columns_to_show$`max [m]`,
    ),
    `unconverted units` = colDef(
      show = FALSE
    ),
    vertical = colDef(
      show = FALSE
    ),
    start = colDef(
      show = columns_to_show$start,
      format = colFormat(date = TRUE, locales = "en-GB")
    ),
    end = colDef(
      show = columns_to_show$end,
      format = colFormat(date = TRUE, locales = "en-GB")
    ),
    `Temporal type` = colDef(
      show = columns_to_show$`Temporal type`
    ),
    `Coverage (spatial)` = colDef(
      show = columns_to_show$`Coverage (spatial)`
    ),
    type = colDef(
      show = columns_to_show$type
    ),
    format = colDef(
      show = columns_to_show$format
    ),
    `file extension` = colDef(
      show = columns_to_show$`file extension`
    ),
    `Coordinate reference system` = colDef(
      show = FALSE
    ),
    Download = colDef(
      html = TRUE,
      name = "Download",
      cell = JS('
    function(cellInfo) {
      // Render as a link
      const url = `${cellInfo.value}`
      return `<a href="${url}" target="_blank">link</a>`
    }
  ')
    ),
    Publisher = colDef(
      show = FALSE,
      vAlign = "center"
      # cell = function(value, index, name) {
      #   render_reactable_cell_with_tippy(text = value, tooltip = value)
      # }
    ),
    `Published first` = colDef(
      show = FALSE
    ),
    Literature = colDef(
      html = TRUE,
      name = "Literature",
      cell = JS('
    function(cellInfo) {
      // Render as a link
      const url = `${cellInfo.value}`
      return `<a href="${url}" target="_blank">link</a>`
    }
  ')
    ),
    `Version updates` = colDef(
      show = columns_to_show$`Version updates`,
      name = "Version updates",
      cell = reactablefmtr::icon_sets(
        table_data,
        icon_ref = "version_update_icons",
        icon_color_ref = "version_update_icon_colors",
        icon_position = "over"
      )
    ),
    Access = colDef(
      show = columns_to_show$Access
    ),
    License = colDef(
      show = FALSE,
      minWidth = 160
    ),
    `Data limitations` = colDef(
      show = FALSE
    ),
    Method = colDef(
      show = FALSE
    ),
    `Usage requirement` = colDef(
      show = FALSE
    ),
    minTempRes = colDef(
      show = FALSE
    ),
    maxTempRes = colDef(
      show = FALSE
    ),
    Comment = colDef(
      show = FALSE,
      name = "Comment"
      # cell = function(value, index, name) {
      #   render_reactable_cell_with_tippy(text = value, tooltip = value)
      # }
    ),
    version_update_icons = colDef(
      show = FALSE
    ),
    version_update_icon_colors = colDef(
      show = FALSE
    ),
    domain_icon_colors = colDef(
      show = FALSE
    )
  )
}
