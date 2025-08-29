#' Literature Table UI – v2 (final 14 columns)
mod_table_ui <- function(id) {
  ns <- NS(id)
  reactable::reactableOutput(ns("lit_tbl"))
}

#' Literature Table Server – v2
mod_table_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    output$lit_tbl <- reactable::renderReactable({
      reactable::reactable(
        data()[, c(
          "pmid","publisher", "disease_name", "biomarker", "baseline", "pathology",
          "stage","survey_start_dt", "survey_end_dt",
          "data_source_year","epid_index", "country_region" 
        )],
        searchable       = TRUE,
        filterable       = TRUE,
        pagination       = TRUE,
        defaultPageSize  = 20,
        striped          = TRUE,
        outlined         = TRUE,
        highlight        = TRUE,
        compact          = TRUE
      )
    })
  })
}