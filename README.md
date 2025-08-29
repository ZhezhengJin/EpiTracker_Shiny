# 📊 EpiTracker — 流行病学数据增量管理平台

## 📌 项目简介
EpiTracker 是一个基于 **R + Shiny (shinydashboardPlus)** 的流行病学文献数据管理与可视化平台，支持：

- **结构化数据管理**：原始流病文献数据（Parquet 格式）读取、清洗、标准化  
- **动态可视化展示**：总览统计、年度趋势、地区分布、疾病/指标排名  
- **增量数据更新**：新旧版本对比，自动记录新增文献/数据量  
- **日志与留言板**：基于 SQLite 的持久化存储，支持多人协作与历史追溯  
- **版本管理**：版本日志由外部 `yaml` 文件维护，可直接在前端展示  

详细升级内容见 [shinyapp/configs/version_log.yaml] 

---

## 📂 项目结构
```bash
EpiTracker-Project/
├── shinyapp/
|   ├── app.R                  # Shiny 应用入口
|   ├── runtime/               # 运行时数据库 (autoupdate_log.sqlite)
|   ├── configs/               # 配置文件 (version_log.yaml)
|   ├── rsconnnect/            # RStudio Connect 部署脚本
|   ├── app_data/              # 部署app所需的数据文件
|   └── modules/
│      ├── mod_overview.R
│      ├── mod_table.R
│      ├── mod_search.R
│      ├── mod_autoupdate.R
│      ├── mod_version_log.R
│      └── mod_message_board.R
├── data/
│   ├── raw                    # 原始数据 (meta_raw_*.parquet)
│   ├── processed              # 清洗脚本 (Data_clean_SOP.Rmd)
│   ├── lastest                # 最新数据快照 (data_latest.parquet)
│   └── exports                # 导出sample数据
├── docs/                      # 数据处理SOP.rmd
├── prompts/                   # 用于生成初版shinyapp的Prompt 
└── README.md                  # 项目说明
```

---

## ⚙️ 技术栈
- 语言: R  
- 前端框架: Shiny + shinydashboardPlus  
- 数据处理: arrow (Parquet), tidyverse  
- 数据库: SQLite (日志与留言板持久化)  
- 可视化: plotly, ggplot2, leaflet  
- 表格渲染: reactable  
- 配置与版本日志: yaml  
- 依赖管理: pacman, here  

---

## 🚀 使用方法

### 1. 准备环境
```r
if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(shiny,shinydashboard,shinydashboardPlus,
               reactable,plotly,tidyverse,leaflet,
               rnaturalearth,rnaturalearthdata,sf,
               jsonlite,DBI,RSQLite,yaml, arrow)
               
options(jsonlite.simplifyVector = TRUE)
```

### 2. 数据预处理
在 [docs/Data_clean_SOP.Rmd] 中运行数据清洗流程：  
- **输入**: `data/raw/meta_raw_*.parquet`  
- **输出**: `data/latest/data_latest.parquet`  

### 3. 启动 Shiny 应用
```r
shiny::runApp("shinyapp")
```

---

## 📊 功能模块

### 总览 (Overview)
- 文献数、疾病数、地区数、年度趋势、疾病/指标 Top 排行  
- 地图分布（leaflet）  

### 检索 (Search)
- 按字段 (`disease_name`, `biomarker` 等) 支持 AND/OR 搜索  
- 展示去重后的 unique pmid 结果与摘要表格  

### 原始数据表 (Literature Table)
- 显示完整清洗后的数据表（数万条记录）  

### 数据增量日志 (Auto-update Log)
- 自动比较新旧数据快照  
- 记录新增文献数、总文献数、上传时间  

### 版本日志 (Version Log)
- 读取 `configs/version_log.yaml`  
- 前端可视化展示所有历史版本与更新说明  

### 留言板 (Message Board)
- SQLite 持久化留言，支持多用户并发  

---

## 👤 维护者
- Adam (2025)