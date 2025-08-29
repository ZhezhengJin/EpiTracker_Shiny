#' Literature Table UI – v3 (带下载按钮)
mod_table_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(12,
             downloadButton(ns("download_csv"), "Download CSV"),
             downloadButton(ns("download_xlsx"), "Download Excel")
      )
    ),
    # IMPORTANT: put withSpinner around the UI output (reactableOutput),
    # not around renderReactable in server.
    shinycssloaders::withSpinner(reactable::reactableOutput(ns("lit_tbl")), type = 6)
  )
}

#' Literature Table Server – v3 (带导出功能)
mod_table_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    selected_cols <- c(
      "pmid","publisher", "disease_name", "biomarker", "baseline", "pathology",
      "stage","survey_start_dt", "survey_end_dt",
      "data_source_year","epid_index", "country_region"
    )
    
    # --- Downloads (server-side) -------------------------------------
    output$download_csv <- downloadHandler(
      filename = function() paste0("literature_export_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(data()[, selected_cols, drop = FALSE],
                  file, row.names = FALSE, fileEncoding = "UTF-8")
      }
    )
    
    output$download_xlsx <- downloadHandler(
      filename = function() paste0("literature_export_", Sys.Date(), ".xlsx"),
      content = function(file) {
        writexl::write_xlsx(data()[, selected_cols, drop = FALSE], file)
      }
    )
    
    # --- Table render (server only assigns renderReactable) ----------
    output$lit_tbl <- reactable::renderReactable({
      reactable::reactable(
        data()[, selected_cols, drop = FALSE],
        pagination = TRUE,
        showPageSizeOptions = TRUE,
        pageSizeOptions = c(10, 20, 50, 100),
        defaultPageSize = 20,
        filterable = TRUE,
        searchable = TRUE,
        striped = TRUE,
        compact = TRUE,
        highlight = TRUE
      )
    })
  })
}