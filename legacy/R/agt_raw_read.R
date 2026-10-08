#' read table
#'
#' @param filepath filepath.
#' @return a tibble.
#' @export
#'
agt_raw_read <- function(filepath) {
  read_sheet(
    "18V8HpVDG3BVBxv03jbg-m1ZCnbz3R7t4Asty_Ub_tfw",
    col_types = "c",
    col_names = FALSE
  )
}
