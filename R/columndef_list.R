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
      minWidth = 200
    ),
    Unit = colDef(cell = function(value) {
      # Omit inline = TRUE to render math in display mode
      katexR::katex(value, inline = TRUE)
    }),
    min = colDef(
      name = "min",
      width = 300,
      cell = reactablefmtr::color_tiles(
        data = table_data,
        colors = viridis::mako(n = 17, begin = 0, end = 0.7, direction = -1), #MetBrewer::met.brewer("VanGogh3", n = 5, direction = -1),
        opacity = 0.5,
        bold_text = TRUE,
        box_shadow = TRUE
      )
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
      cell = function(value, index) {
        if (stringr::str_detect(value, "http") | is.na(value)) {
          htmltools::tags$a(href = value, target = "_blank", "link")
        } else {
          "no link yet"
        }
      }
    ),
    Literature = colDef(
      name = "Literature",
      cell = function(value, index) {
        if (stringr::str_detect(value, "http") | is.na(value)) {
          htmltools::tags$a(href = value, target = "_blank", "link")
        } else {
          "no link yet"
        }
      }
    ),
    Comment = colDef(
      name = "Comment",
      cell = function(value, index, name) {
        render_reactable_cell_with_tippy(text = value, tooltip = value) }
    )
  )
}