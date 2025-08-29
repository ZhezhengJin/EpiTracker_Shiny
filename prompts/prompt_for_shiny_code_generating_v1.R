You are an expert in Shiny app development using `golem` structure and clean design. I am building a Shiny Dashboard to visualize and monitor structured epidemiology literature data. Please help me generate a clean, modular Shiny app (golem-style project) suitable for UI prototyping and functional testing. 

---
  
  ## ✅ Project Structure
  
  Use the standard `golem` modular structure:
  - `/R/` folder with: 
  - `app_ui.R`, `app_server.R`, 
- `mod_overview.R`, `mod_table.R`, `mod_index.R`, `mod_search.R`, 
- `utils_data.R` (for mock data), 
- `/www/` folder for styles (optional)
- `/app.R` as the main launcher

Keep the UI layout elegant, use `shinydashboardPlus`, and follow a **simple, minimal, aesthetic design**, with clearly separated modules.

---
  
  ## 🧾 Data Simulation
  
  Create a function `generate_mock_data()` inside `utils_data.R` that builds a mock dataset of ~500 rows. Include these fields:
  
  - `data_source_url`: simulated numeric PMID
- `data_source_title`: fake titles
- `data_source_publisher`: sampled from journals
- `data_source_year`: year between 1995-2024
- `raw_country_region`: sample from common countries
- `raw_epid_index`: e.g., "Prevalence", "Incidence"
- `raw_index_value`: realistic numeric values
- `raw_index_unit`: e.g., "%", "per 100,000"
- `real_stat_dt`, `survey_start_dt`, `survey_end_dt`: random year or blank
- `gen_disease_name`: 10 sample diseases
- `gen_biomarker`, `gen_stage`, `gen_pathology`, `gen_baseline`: short text

Use only `tibble`, `sample`, `runif`, `glue`, etc. to generate it. No external files needed.

---
  
  ## 🧱 Required Modules (one .R file per module)
  
  Each module should follow `mod_*` convention. Design these modules:
  
  1. **Overview (mod_overview.R)**
  - valueBoxes: total records, distinct countries, distinct diseases
- Line plot: number of publications per year
- Bar plot: Top 10 diseases

2. **Literature Table (mod_table.R)**
  - `reactable` table showing simplified fields
- Searchable, paginated, sorted

3. **Index Explorer (mod_index.R)**
  - selectInput to choose `raw_epid_index`
- plotly chart: value distribution
- pie chart: unit distribution

4. **Keyword Search (mod_search.R)**
  - textInput for keyword
- filterable reactable table

---
  
  ## 🎨 UI / Design Guidelines
  
  - Use `shinydashboardPlus` layout
- Avoid deeply nested UI or reactive graphs unless necessary
- Keep sidebar minimal
- Use clear labels and section titles
- Add basic style in `/www/` (optional)

---
  
  ## 🛠️ Development Notes
  
  - Avoid using `DT`, `shinyWidgets`, or complex JS plugins
- Ensure every module is runnable and self-contained
- Include minimal error handling
- Include comments and use `golem::add_module(name = "")` style as reference
- No file upload or auth features

---
  
  Now please generate all necessary files for this `golem` app, including:
  1. `/R/utils_data.R` with `generate_mock_data()`
2. `/R/mod_overview.R`, `/R/mod_table.R`, `/R/mod_index.R`, `/R/mod_search.R`
3. `/R/app_ui.R` and `/R/app_server.R`
4. `/app.R` main launcher

Make sure all files are clean, runnable, and support local testing. This is for frontend UI + logic prototyping.
