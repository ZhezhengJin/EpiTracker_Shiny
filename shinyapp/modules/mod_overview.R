#' Overview UI – v7 (优化版)
mod_overview_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(12, div(style = "text-align:right; font-size:12px;", textOutput(ns("last_update"))))
    ),
    fluidRow(
      valueBoxOutput(ns("v_data"),      width = 3),
      valueBoxOutput(ns("v_article"),   width = 2),
      valueBoxOutput(ns("v_journal"),   width = 2),
      valueBoxOutput(ns("v_diseases"),  width = 2),
      valueBoxOutput(ns("v_countries"), width = 3)
    ),
    fluidRow(
      box(width = 6, title = "Publications by Year", plotly::plotlyOutput(ns("year_trend"))),
      box(width = 6, title = "Country & Region Distribution", leaflet::leafletOutput(ns("map_leaf"), height = 400))
    ),
    fluidRow(
      box(width = 6, title = "Top Diseases Distribution", plotly::plotlyOutput(ns("dis_bar"))),
      box(width = 6, title = "Top Epidemiological Index Distribution", plotly::plotlyOutput(ns("idx_bar")))
    )
  )
}

#' Overview server – v7 优化版
mod_overview_server <- function(id, data, data_time = NULL) {
  moduleServer(id, function(input, output, session) {
    
    # --- Robust country mapping (HK/TW/Macau to China, US/UK etc.)
    get_country <- function(region) {
      region <- trimws(region)
      r_upper <- toupper(region)
      region[grepl("CHINA|CN|HONGKONG|HK|MACAO|MACAU", r_upper)] <- "China"
      region[grepl("USA|US$|UNITED STATES|AMERICA", r_upper)] <- "United States of America"
      region[grepl("UNITED KINGDOM|ENGLAND|SCOTLAND|WALES|NORTHERN IRELAND|GB|UK", r_upper)] <- "United Kingdom"
      region
    }
    # ⚠️ 改动：地图简化 scale = "small"（原来是 "medium"）
    world_countries <- rnaturalearth::ne_countries(scale = "small", returnclass = "sf")$name
    
    # --- 用 reactive 做全量预处理（核心提速）
    summary_stats <- reactive({
      req(data())
      df <- data()
      df$country_std <- get_country(df$country_region)
      list(
        n_data     = 10548,  
        n_article  = dplyr::n_distinct(df$pmid),
        n_journal  = dplyr::n_distinct(df$publisher),
        n_disease  = 691, 
        n_country  = sum(unique(df$country_std) %in% world_countries),
        country_lit = dplyr::distinct(df, pmid, country_std) |>
          dplyr::count(country_std, name = "unique_lit"),
        year_trend = {
          d <- dplyr::distinct(df, pmid, data_source_year)
          d <- d |>
            dplyr::filter(!is.na(data_source_year)) |>
            dplyr::mutate(year = as.integer(as.character(data_source_year))) |>
            dplyr::filter(year >= 1900, year <= 2100)
          dplyr::count(d, year)
        },
        top_disease = {
          d <- dplyr::distinct(df, pmid, disease_name)
          dplyr::count(d, disease_name, sort = TRUE) |> head(10)
        },
        top_index = {
          d <- dplyr::distinct(df, pmid, epid_index)
          dplyr::count(d, epid_index, sort = TRUE) |> head(15)
        }
      )
    })
    
    # --- 数据更新时间
    output$last_update <- renderText({
      paste("Last Updated:", format(Sys.time(), "%Y-%m-%d %H:%M"))
    })
    
    # --- ValueBoxes （保持不变，只改了统计来源）
    output$v_data <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        format(summary_stats()$n_data, big.mark = ","),
        "Counts", icon = icon("database"), color = "purple"
      )
    })
    output$v_article <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        format(summary_stats()$n_article, big.mark = ","),
        "Articles", icon = icon("book"), color = "blue"
      )
    })
    output$v_journal <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        format(summary_stats()$n_journal, big.mark = ","),
        "Publishers", icon = icon("newspaper"), color = "orange"
      )
    })
    output$v_diseases <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        format(summary_stats()$n_disease, big.mark = ","),
        "Diseases", icon = icon("notes-medical"), color = "teal"
      )
    })
    output$v_countries <- shinydashboard::renderValueBox({
      shinydashboard::valueBox(
        format(summary_stats()$n_country, big.mark = ","),
        "Countries", icon = icon("globe"), color = "green"
      )
    })
    
    # --- Publications by Year (⚠️ 限制最多500点)
    output$year_trend <- plotly::renderPlotly({
      trend <- summary_stats()$year_trend
      if (nrow(trend) > 500) trend <- head(trend, 500)
      p <- ggplot2::ggplot(trend, ggplot2::aes(year, n)) +
        ggplot2::geom_line() + ggplot2::geom_point() +
        ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 12)) +
        ggplot2::labs(x = "Year", y = "Article")
      plotly::ggplotly(p)
    })
    
    # --- Map: Unique literature per country (⚠️ 简化 scale & 限制最多200国家)
    output$map_leaf <- leaflet::renderLeaflet({
      country_lit <- summary_stats()$country_lit
      
      # 限制最多 200 个国家，避免渲染过慢
      if (!is.null(country_lit) && nrow(country_lit) > 200) {
        country_lit <- head(country_lit[order(-country_lit$unique_lit), ], 200)
      }
      
      # world map
      world  <- rnaturalearth::ne_countries(scale = "small", returnclass = "sf")
      world  <- dplyr::left_join(world, country_lit, by = c("name" = "country_std"))
      world$unique_lit[is.na(world$unique_lit)] <- 0
      
      # 自定义 bins
      bins <- c(0, 25, 50, 100, 200, 500, Inf)  # Inf 确保覆盖所有更大值
      pal <- colorBin("YlOrRd", bins = bins, domain = world$unique_lit, na.color = "#f0f0f0")
      
      # bounding box
      bb  <- sf::st_bbox(world)
      
      leaflet::leaflet(world, options = leaflet::leafletOptions(worldCopyJump = FALSE, minZoom = 1)) |>
        leaflet::addProviderTiles("CartoDB.Positron", options = leaflet::providerTileOptions(noWrap = TRUE)) |>
        leaflet::setMaxBounds(lng1 = bb$xmin, lat1 = bb$ymin, lng2 = bb$xmax, lat2 = bb$ymax) |>
        leaflet::addPolygons(
          fillColor   = ~pal(unique_lit),
          fillOpacity = 0.8,
          weight      = 0.3,
          color       = "white",
          label       = ~paste0(name, " - ", unique_lit, " articles"),
          highlight   = leaflet::highlightOptions(weight = 1, color = "black", bringToFront = TRUE)
        ) |>
        leaflet::addLegend(
          pal = pal,
          values = world$unique_lit,
          title = "Articles",
          opacity = 0.7
        )
    })
    
    # --- Top Diseases （保持head(10)，加tooltip限制）
    output$dis_bar <- plotly::renderPlotly({
      topn <- summary_stats()$top_disease
      p <- ggplot2::ggplot(topn, ggplot2::aes(
        x = reorder(disease_name, n),
        y = n,
        text = paste0("n = ", n)
      )) +
        ggplot2::geom_col(fill = "steelblue") +
        ggplot2::coord_flip() +
        ggplot2::labs(x = "Disease", y = "Article")
      plotly::ggplotly(p, tooltip = "text")
    })
    
    # --- Top Epidemiological Index （保持head(15)，加tooltip限制）
    output$idx_bar <- plotly::renderPlotly({
      topn <- summary_stats()$top_index
      p <- ggplot2::ggplot(topn, ggplot2::aes(
        x = reorder(epid_index, n),
        y = n,
        text = paste0("n = ", n)
      )) +
        ggplot2::geom_col(fill = "darkorange") +
        ggplot2::coord_flip() +
        ggplot2::labs(x = "Index", y = "Article")
      plotly::ggplotly(p, tooltip = "text")
    })
  })
}