sv_date_order <- function() {
  compose_rules(
    ~if ((.[2] <= .[1]) & !is.na(.[2] <= .[1])) "Please enter a 'to'-date that is greater than the 'from'-date",
    ~if ((.[1] %>% is.na()) & !(.[2] %>% is.na())) "Please leave either both dates empty or enter at least the first date"
  )
}