# 读取yaml
version_log <- read_yaml("configs/version_log.yaml")

# 转为tibble/data.frame
version_log_df <- bind_rows(version_log)
version_log_df$notes <- gsub("\n", "<br>", version_log_df$notes)

# UI
mod_log_ui <- function(id) {
  ns <- NS(id)
  tabItem(
    tabName = "version_log",
    h2("App 版本记录"),
    reactable::reactableOutput(ns("version_log"))
  )
}

# Server
mod_log_server <- function(id, version_log_df) {
  moduleServer(id, function(input, output, session) {
    output$version_log <- reactable::renderReactable({
      reactable::reactable(
        version_log_df,
        columns = list(
          version = colDef(name = "版本号"),
          date = colDef(name = "发布日期"),
          notes = colDef(name = "更新内容", html = TRUE),  # <<<<<< 这里!
          maintainer = colDef(name = "维护人")
        ),
        bordered = TRUE,
        striped = TRUE,
        highlight = TRUE
      )
    })
  })
}