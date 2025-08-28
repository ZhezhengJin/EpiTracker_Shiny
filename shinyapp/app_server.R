if (!dir.exists("data")) dir.create("data")

data_latest <- read_parquet("data/data_latest.parquet") # 可根据文件实际位置调整
data_latest_time <- as.POSIXct("2025/07/15 14:30", tz = "Asia/Shanghai") # 手动定义第一次上传数据时间，后续更新统一使用Sys.time()

save(data_latest, data_latest_time, file = "data/data_latest.RData")
load("data/data_latest.RData")

app_server<-function(input,output,session){
  data <- reactiveVal(data_latest)
  data_time <- reactiveVal(data_latest_time)
  mod_overview_server("overview",data)
  mod_table_server   ("table",   data)
  mod_search_server  ("search",  data)
  mod_autoupdate_server("update", data = data, data_time = data_time, 
                        db_path = "shinyapp/autoupdate_log.sqlite")
  mod_log_server("version_log", version_log_df)                           
  mod_message_board_server("message_board", db_path = "shinyapp/autoupdate_log.sqlite")
}