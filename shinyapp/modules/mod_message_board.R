ensure_message_board_table <- function(db_path, table = "message_board") {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  if (!DBI::dbExistsTable(con, table)) {
    DBI::dbExecute(con, sprintf(
      "CREATE TABLE %s (
        time TEXT,
        user TEXT,
        message TEXT,
        note TEXT
      )", table
    ))
  }
  DBI::dbDisconnect(con)
}


# shinyapp/mod_message_board.R
mod_message_board_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(3, textInput(ns("user"), "留言人")),
      column(6, textInput(ns("message"), "留言内容")),
      column(3, actionButton(ns("submit"), "提交留言", icon = icon("paper-plane")))
    ),
    br(),
    reactable::reactableOutput(ns("message_board_tbl"))
  )
}

mod_message_board_server <- function(id, db_path = "shinyapp/autoupdate_log.sqlite", table = "message_board") {
  moduleServer(id, function(input, output, session) {
    ensure_message_board_table(db_path, table)
    
    observeEvent(input$submit, {
      req(input$user, input$message)
      con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
      new_row <- data.frame(
        time = format(Sys.time(), "%Y-%m-%d %H:%M"),
        user = input$user,
        message = input$message,
        note = "",
        stringsAsFactors = FALSE
      )
      DBI::dbWriteTable(con, table, new_row, append = TRUE, row.names = FALSE)
      DBI::dbDisconnect(con)
      # 可选：清空输入
      updateTextInput(session, "user", value = "")
      updateTextInput(session, "message", value = "")
    })
    
    output$message_board_tbl <- reactable::renderReactable({
      con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
      board <- DBI::dbReadTable(con, table)
      DBI::dbDisconnect(con)
      reactable::reactable(
        board,
        columns = list(
          time = colDef(name = "时间"),
          user = colDef(name = "留言人"),
          message = colDef(name = "内容"),
          note = colDef(name = "备注", show = FALSE)
        ),
        bordered = TRUE,
        striped = TRUE,
        highlight = TRUE
      )
    })
  })
}