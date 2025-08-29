#' Keyword Explorer UI – v5
#' Distinct from Literature tab: sidebar filter + tabbed outputs
mod_search_ui <- function(id) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(width = 3, 
                 textInput(ns("kw"), "Keyword", placeholder = "Type to search…"),
                 selectInput(ns("field"), "Search Field",
                             choices = c("Disease" = "disease_name",
                                         "Biomarker" = "biomarker",
                                         "Pathology" = "pathology",
                                         "Baseline" = "baseline",
                                         "Stage" = "stage"),
                             selected = "disease_name"),
                 checkboxInput(ns("and_mode"), "Use AND between words", value = TRUE),
                 hr(), # 横线
                 tags$div(style = "margin-top: 20px;"), 
                 # quick stats
                 valueBoxOutput(ns("v_found"), width = 12)
    ),
    mainPanel(width = 9,
              tabsetPanel(id = ns("tabs"),
                          tabPanel("List", reactable::reactableOutput(ns("kw_tbl")))
              )
    )
  )
}

#' Keyword Explorer Server – v5
mod_search_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # --- helper: token‑based filter -------------------------------------
    token_filter <- function(df, column, keyword, and_mode = TRUE) {
      if (is.null(keyword) || keyword == "") return(df[0, ])
      tokens <- unlist(strsplit(keyword, "\\s+"))
      pattern_vec <- paste0("(?i)", tokens) # case‑insensitive
      hits <- sapply(pattern_vec, function(pt) grepl(pt, df[[column]], ignore.case = TRUE))
      keep <- if (and_mode) apply(hits, 1, all) else apply(hits, 1, any)
      df[keep, ]
    }
    
    # reactive filtered data ---------------------------------------------
    filt <- reactive({
      req(input$kw)
      token_filter(data(), input$field, trimws(input$kw), input$and_mode)
    })
    
    # quick stats ---------------------------------------------------------
    output$v_found <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(nrow(filt()), "Records Found", icon = icon("search"))
    })
    
    # summary table (always exclude search field column)
    output$kw_tbl <- reactable::renderReactable({
      req(nrow(filt()) > 0)
      cols_all <- c("disease_name", "biomarker", "baseline", "pathology", "stage", "country_region")
      search_field <- input$field
      # 只保留除搜索字段外的列
      cols <- setdiff(cols_all, search_field)
      
      col_map <- c(
        disease_name = "Disease",
        biomarker = "Biomarker",
        baseline = "Baseline",
        pathology = "Pathology",
        stage = "Stage",
        country_region = "Country/Region"
      )
      
      lst <- lapply(cols, function(cl) {
        vals <- unique(filt()[[cl]])
        vals <- vals[!is.na(vals) & nzchar(as.character(vals))]
        vals <- sort(as.character(vals))
        paste(vals, collapse = ";; ")
      })
      
      # Calculate Survey Range (min start, max end)
      s_start <- suppressWarnings(as.numeric(filt()$survey_start_dt))
      s_end   <- suppressWarnings(as.numeric(filt()$survey_end_dt))
      survey_range <- if (all(is.na(s_start)) & all(is.na(s_end))) {
        ""
      } else {
        paste0(
          min(s_start, s_end, na.rm = TRUE), " - ",
          max(s_start, s_end, na.rm = TRUE)
        )
      }
      
      fields_label <- unname(col_map[cols])
      summary_tbl <- data.frame(
        Field = c(fields_label, "Survey Range"),
        Unique_Values = c(unlist(lst), survey_range),
        stringsAsFactors = FALSE
      )
      
      reactable::reactable(
        summary_tbl,
        columns = list(
          Field = reactable::colDef(name = "Field", width = 200),
          Unique_Values = reactable::colDef(
            name = "Unique Values",
            html = TRUE,
            width = 1000,
            style = list(whiteSpace = "pre-wrap")
          )
        ),
        sortable = FALSE,
        filterable = FALSE,
        pagination = FALSE,
        compact = TRUE,
        minRows = 1
      )
    })
  })
}