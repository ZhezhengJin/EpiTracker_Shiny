# ---- Auto install & load all packages
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(shiny,shinydashboard,shinydashboardPlus,
               reactable,plotly,tidyverse,leaflet,
               rnaturalearth,rnaturalearthdata,sf,
               jsonlite,DBI,RSQLite,yaml, arrow, shinycssloaders)

options(jsonlite.simplifyVector = TRUE)

# Source internal files ---------------------------------------------------
source("modules/mod_overview.R", local = TRUE)
source("modules/mod_table.R",    local = TRUE)
source("modules/mod_autoupdate.R",    local = TRUE)
source("modules/mod_search.R",   local = TRUE)
source("modules/mod_version_log.R",   local = TRUE)
source("modules/mod_message_board.R",   local = TRUE)

# UI ----------------------------------------------------------------------
app_ui<-function(request){shinydashboardPlus::dashboardPage(
  dashboardHeader(title="流病数据增量管理平台"),
  dashboardSidebar(sidebarMenu(
    menuItem("数据总览",tabName="overview",icon=icon("dashboard")),
    menuItem("原始数据",tabName="table",icon=icon("table")),
    menuItem("关键词检索",tabName="search",icon=icon("search")),
    menuItem("数据更新记录",tabName="update",icon=icon("sync")),
    menuItem("版本日志", tabName = "version_log", icon = icon("clipboard-list")),
    menuItem("留言板", tabName = "message_board", icon = icon("comments"))
  )),
  dashboardBody(tabItems(
    tabItem(tabName="overview",mod_overview_ui("overview")),
    tabItem(tabName="table",  mod_table_ui("table")),
    tabItem(tabName="search", mod_search_ui("search")),
    tabItem(tabName="update", mod_autoupdate_ui("update")),
    tabItem(tabName = "version_log",       mod_log_ui("version_log")),               
    tabItem(tabName = "message_board", mod_message_board_ui("message_board"))
  )),title="流病数据增量管理平台") }

# Server -------------------------------------------------------------------
# 本地部署
# data_latest <- read_parquet("data/processed/data_latest.parquet") 
# data_latest_time <- as.POSIXct("2025/07/15 14:30", tz = "Asia/Shanghai") # 第一次手动定义时间，后续更新用 Sys.time()
# # save(data_latest, data_latest_time, file = "app_data/data_latest.RData")
# load("data/lastest/data_latest.RData")

# app部署
data_latest <- read_parquet("app_data/data_latest.parquet") 
data_latest_time <- as.POSIXct("2025/07/15 14:30", tz = "Asia/Shanghai") # 第一次手动定义时间，后续更新用 Sys.time()

app_server <- function(input, output, session) {
  data <- reactiveVal(data_latest)
  data_time <- reactiveVal(data_latest_time)
  
  mod_overview_server("overview", data)
  mod_table_server   ("table",   data)
  mod_search_server  ("search",  data)
  
  # 运行时数据库 
  mod_autoupdate_server("update", 
                        data = data, 
                        data_time = data_time, 
                        db_path = "runtime/autoupdate_log.sqlite")
  
  # 版本日志 
  mod_log_server("version_log", version_log_df)
  
  mod_message_board_server("message_board", 
                           db_path = "runtime/autoupdate_log.sqlite")
}

# Launch ------------------------------------------------------------------
shinyApp(ui = app_ui, server = app_server)



