set_levels <- function(x, var, levels_new) {
  x %>%
    mutate({{ var }} := factor({{ var }}, levels_new))
}