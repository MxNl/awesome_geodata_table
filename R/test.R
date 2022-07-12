library(reactable)
library(dplyr)

iris

data <- iris |>
  as_tibble() |>
  mutate(
    latex = rep_len(
      c("$$frac{m}{s}$$", "$$m_equ$$", "unknown"), length.out = nrow(iris)),
    .before = 1
  )

data |>
  reactable()