# ---- Auto install & load all packages
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(shiny,shinydashboard,shinydashboardPlus,
               reactable,plotly,tidyverse,leaflet,
               rnaturalearth,rnaturalearthdata,sf,
               jsonlite,DBI,RSQLite,yaml, arrow)

options(jsonlite.simplifyVector = TRUE)

# Source internal files ---------------------------------------------------
source("shinyapp/mod_overview.R", local = TRUE)
source("shinyapp/mod_table.R",    local = TRUE)
source("shinyapp/mod_autoupdate.R",    local = TRUE)
source("shinyapp/mod_search.R",   local = TRUE)
source("shinyapp/mod_version_log.R",   local = TRUE)
source("shinyapp/mod_message_board.R",   local = TRUE)
source("shinyapp/app_ui.R",       local = TRUE)
source("shinyapp/app_server.R",   local = TRUE)

# Launch ------------------------------------------------------------------
shinyApp(ui = app_ui, server = app_server)



