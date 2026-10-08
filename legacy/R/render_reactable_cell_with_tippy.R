render_reactable_cell_with_tippy <- function(text, tooltip) {
  shiny::div(
    style = "cursor: info;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;",
    tippy::tippy(text = text, tooltip = tooltip)
  )
}