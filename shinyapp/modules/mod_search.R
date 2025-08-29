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
                 hr(),
                 tags$div(style = "margin-top: 20px;"), 
                 shinycssloaders::withSpinner(valueBoxOutput(ns("v_found"), width = 12), type = 6)
    ),
    mainPanel(width = 9,
              tabsetPanel(id = ns("tabs"),
                          tabPanel("List", shinycssloaders::withSpinner(reactable::reactableOutput(ns("kw_tbl")), type = 6))
              )
    )
  )
}

#' Keyword Explorer Server – v7 (优化 + 加载动画)
mod_search_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    # token_based filter
    token_filter <- function(df, column, keyword, and_mode = TRUE) {
      if (is.null(keyword) || keyword == "") return(df[0, , drop = FALSE])
      tokens <- unlist(strsplit(keyword, "\\s+"))
      # guards
      if (length(tokens) == 0) return(df[0, , drop = FALSE])
      hits <- sapply(tokens, function(pt) grepl(pt, df[[column]], ignore.case = TRUE))
      # if only one token, sapply returns vector -> coerce to matrix
      if (is.vector(hits)) hits <- matrix(hits, ncol = 1)
      keep <- if (and_mode) apply(hits, 1, all) else apply(hits, 1, any)
      df[keep, , drop = FALSE]
    }
    
    filt <- reactive({
      req(input$kw)
      df <- data()
      if (is.null(df) || nrow(df) == 0) return(df[0, , drop = FALSE])
      token_filter(df, input$field, trimws(input$kw), input$and_mode)
    })
    
    # valueBox (server must only assign renderValueBox)
    output$v_found <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        value = nrow(filt()),
        subtitle = "Records Found",
        icon = icon("search")
      )
    })
    
    # summary precompute reactive
    filt_summary <- reactive({
      df <- filt()
      # ensure df exists
      if (is.null(df) || nrow(df) == 0) {
        return(data.frame(Field = "No matches", Unique_Values = "", stringsAsFactors = FALSE))
      }
      
      cols_all <- c("disease_name", "biomarker", "baseline", "pathology", "stage", "country_region")
      search_field <- input$field
      cols <- setdiff(cols_all, search_field)
      col_map <- c(
        disease_name   = "Disease",
        biomarker      = "Biomarker",
        baseline       = "Baseline",
        pathology      = "Pathology",
        stage          = "Stage",
        country_region = "Country/Region"
      )
      
      uniq_vals <- vapply(cols, function(cl) {
        vals <- unique(df[[cl]])
        vals <- vals[!is.na(vals) & nzchar(as.character(vals))]
        vals <- sort(as.character(vals))
        if (length(vals) > 200) vals <- c(head(vals, 200), "... (truncated)")
        paste(vals, collapse = ";; ")
      }, FUN.VALUE = character(1))
      
      # survey range
      s_start <- suppressWarnings(as.numeric(df$survey_start_dt))
      s_end   <- suppressWarnings(as.numeric(df$survey_end_dt))
      if (all(is.na(s_start)) && all(is.na(s_end))) {
        survey_range <- ""
      } else {
        survey_range <- paste0(min(c(s_start, s_end), na.rm = TRUE), " - ", max(c(s_start, s_end), na.rm = TRUE))
      }
      
      data.frame(
        Field = c(unname(col_map[cols]), "Survey Range"),
        Unique_Values = c(unname(uniq_vals), survey_range),
        stringsAsFactors = FALSE
      )
    })
    
    # render reactable (server only assigns render)
    output$kw_tbl <- reactable::renderReactable({
      df_sum <- filt_summary()
      reactable::reactable(
        df_sum,
        columns = list(
          Field = reactable::colDef(name = "Field", width = 200),
          Unique_Values = reactable::colDef(name = "Unique Values", width = 800, style = list(whiteSpace = "pre-wrap"))
        ),
        sortable = FALSE,
        pagination = FALSE,
        compact = TRUE,
        minRows = 1
      )
    })
  })
}