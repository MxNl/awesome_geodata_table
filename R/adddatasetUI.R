adddatasetUI <- function(id) {
  tagList(
    fluidRow(
      column(
        width = 6,
        offset = 3,
        style = "padding-bottom: 50px",
        textInput(
          NS(id, "Dataset name"),
          "Dateset name",
          value = "",
          placeholder = "Please type in the dataset name",
          width = "100%"
        ),
        textOutput(NS(id, "Dataset name")),
        selectizeInput(
          NS(id, "Parameter"),
          "Parameter",
          choices = unique(table_data$Parameter) %>% sort(),
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = TRUE,
            placeholder = "Please choose a parameter or type in a new parameter name",
            maxItems = 1
          )
        ),
        textOutput(NS(id, "Parameter")),
        selectizeInput(
          NS(id, "Tags"),
          "Tags",
          choices = get_comma_sep_unique_values(),
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = TRUE,
            placeholder = "Please choose a tag or type in a new tag"
          )
        ),
        textOutput(NS(id, "Tags")),
        selectizeInput(
          NS(id, "Unit"),
          "Unit",
          choices = unique(table_data$Unit) %>% sort(),
          selected = character(0),
          multiple = TRUE,
          width = "100%",
          options = list(
            create = TRUE,
            placeholder = "Please choose a unit or type in a new unit in latex equation syntax",
            maxItems = 1
          )
        ),
        textOutput(NS(id, "Tags")),
        selectizeInput(
          NS(id, "Domain"),
          label = "Domain",
          choices = column_categories_domain,
          selected = character(0),
          multiple = TRUE,
          options = list(
            placeholder = "Please choose a domain",
            maxItems = 1
          ),
          width = "100%"
        ),
        textOutput(NS(id, "Domain"))
      ),
      fluidRow(
        column(
          width = 6,
          offset = 3,
          style = "padding-bottom: 100px",
          align = "center",
          actionButton(
            NS(id, "button_send"),
            "Add entry",
            width = "50%"
          )
        )
      )
    )
  )
}