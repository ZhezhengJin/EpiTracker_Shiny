ensure_log_table <- function(db_path, table = "log_hist") {
  con <- dbConnect(RSQLite::SQLite(), db_path)
  if (!dbExistsTable(con, table)) {
    dbExecute(con, sprintf(
      "CREATE TABLE %s (
        time TEXT PRIMARY KEY,
        new_rows INTEGER,
        new_lit INTEGER,
        total_rows INTEGER,
        total_lit INTEGER
      )", table
    ))
  }
  dbDisconnect(con)
}


#' Auto-update UI
mod_autoupdate_ui <- function(id) {
  ns <- NS(id)
  tagList(
    reactable::reactableOutput(ns("log_tbl"))
  )
}

#' Auto-update Server: logs changes vs previous snapshot
mod_autoupdate_server <- function(
    id, data, data_time, 
    db_path = "shinyapp/autoupdate_log.sqlite",
    table = "log_hist"
) {
  moduleServer(id, function(input, output, session) {
    ensure_log_table(db_path, table)
    
    observeEvent(data_time(), {
      update_time <- lubridate::with_tz(data_time(), "Asia/Shanghai")
      update_time_chr <- format(update_time, "%Y-%m-%d %H:%M:%S")
      current <- data()
      
      # 读取历史log
      con <- dbConnect(RSQLite::SQLite(), db_path)
      log_hist <- dbReadTable(con, table)
      # 判断该时间戳是否已追加
      if (!(update_time_chr %in% log_hist$time)) {
        # 取上一次记录，计算差分
        if (nrow(log_hist) > 0) {
          prev <- log_hist[nrow(log_hist), ]
          prev_total <- prev$total_rows
          prev_lit   <- prev$total_lit
        } else {
          prev_total <- NA_integer_
          prev_lit   <- NA_integer_
        }
        new_total <- nrow(current)
        new_lit   <- dplyr::n_distinct(current$pmid)
        delta_rows <- if (!is.na(prev_total)) new_total - prev_total else NA
        delta_lit  <- if (!is.na(prev_lit))   new_lit   - prev_lit   else NA
        
        # 写入新记录
        dbWriteTable(
          con, table, 
          data.frame(
            time = update_time_chr,
            new_rows = delta_rows,
            new_lit = delta_lit,
            total_rows = new_total,
            total_lit = new_lit,
            stringsAsFactors = FALSE
          ),
          append = TRUE, row.names = FALSE
        )
      }
      # 读取全部历史用于展示
      log_hist <- dbReadTable(con, table)
      dbDisconnect(con)
      
      output$log_tbl <- reactable::renderReactable({
        reactable::reactable(
          log_hist,
          columns = list(
            time      = reactable::colDef("更新时间", cell = function(x) htmltools::pre(format(as.POSIXct(x), "%Y/%m/%d\n%H:%M"))),
            new_lit   = reactable::colDef("新增文献量", align = "right"),
            total_lit = reactable::colDef("总文献量", align = "right"),
            new_rows  = reactable::colDef("新增数据量", align = "right"),
            total_rows= reactable::colDef("总数据量", align = "right")
          ),
          compact = TRUE
        )
      })
    }, ignoreNULL = FALSE)
  })
}