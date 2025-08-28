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