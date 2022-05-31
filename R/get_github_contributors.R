get_github_contributors <- function() {
  allcontributors::get_contributors(
    org = "MxNl",
    repo = "awesome_geodata_table"
    ) |> dplyr::pull(logins)
}
