format_domain <- function(x) {

  tag_colours_domain <- x$Domain %>%
    unique() %>%
    length() %>%
    hues::iwanthue(
      cmin = 15,
      cmax = 40,
      lmin = 70,
      lmax = 100
    )

  x %>%
    group_by(Domain) %>%
    mutate(
      domain_icon_colors = tag_colours_domain[cur_group_id()]
    ) %>%
    ungroup()
}