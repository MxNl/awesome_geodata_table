no_letters_feedback <- function(input, id) {
  isletter <- input %>%
    as.numeric() %>%
    is.na() %>%
    suppressWarnings()

  if (!isletter & !is.na(input)) {
    shinyFeedback::showFeedbackDanger(
      id,
      # !isletter,
      text = stringr::str_glue("Please enter a {id} not only consisting of numbers")
    )
  } else {
    shinyFeedback::hideFeedback(id)
  }
}