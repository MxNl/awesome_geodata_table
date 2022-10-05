date_order_feedback <- function(x) {
  id <- "start_end"
  hideFeedback(id)
  if ((x[2] <= x[1]) & !is.na(x[2] <= x[1])) {
    shinyFeedback::showFeedbackDanger(
      id,
      "Please enter a 'to'-date that is greater than the 'from'-date"
    )
  } else if ((x[1] %>% is.na()) & !(x[2] %>% is.na())) {
    shinyFeedback::showFeedbackDanger(
      id,
      "Please leave either both dates empty or enter at least the first date"
    )
  }
}