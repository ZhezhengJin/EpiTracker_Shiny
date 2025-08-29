# 1. 读取最新数据
data_latest <- read_parquet("data/processed/data_latest.parquet") 
data_latest_time <- as.POSIXct("2025/07/15 14:30", tz = "Asia/Shanghai") 
# 第一次手动定义时间，后续更新用 Sys.time()

# 2. 保存为 RData 缓存（方便快速 load）
save(data_latest, data_latest_time, file = "data/latest/data_latest.RData")
load("data/latest/data_latest.RData")

# 3. Shiny server
app_server <- function(input, output, session) {
  data <- reactiveVal(data_latest)
  data_time <- reactiveVal(data_latest_time)
  
  mod_overview_server("overview", data)
  mod_table_server   ("table",   data)
  mod_search_server  ("search",  data)
  
  # 运行时数据库 → 放到 shinyapp/runtime/
  mod_autoupdate_server("update", 
                        data = data, 
                        data_time = data_time, 
                        db_path = "shinyapp/runtime/autoupdate_log.sqlite")
  
  # 版本日志 → configs/version_log.yaml
  mod_log_server("version_log", version_log_df)
  
  mod_message_board_server("message_board", 
                           db_path = "shinyapp/runtime/autoupdate_log.sqlite")
}