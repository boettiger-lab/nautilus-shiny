library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)

df <- readr::read_csv("penguins.csv")
# Find subset of columns that are suitable for scatter plot
df_num <- df |> select(where(is.numeric), -Year)

ui <- page_sidebar(
  theme = bs_theme(bootswatch = "minty"),
  title = "Penguins explorer",
  sidebar = sidebar(
    varSelectInput("xvar", "X variable", df_num, selected = "Bill Length (mm)"),
    varSelectInput("yvar", "Y variable", df_num, selected = "Bill Depth (mm)"),
    checkboxGroupInput("species", "Filter by species",
      choices = unique(df$Species), selected = unique(df$Species)
    ),
    hr(), # Add a horizontal rule
    checkboxInput("by_species", "Show species", TRUE),
    checkboxInput("show_margins", "Show marginal plots", TRUE),
    checkboxInput("smooth", "Add smoother"),
  ),
  plotOutput("scatter")
)

server <- function(input, output, session) {
  subsetted <- reactive({
    req(input$species)
    df |> filter(Species %in% input$species)
  })

  output$scatter <- renderPlot(
    {
      p <- ggplot(subsetted(), aes(!!input$xvar, !!input$yvar)) +
        theme_light() +
        list(
          theme(legend.position = "bottom"),
          if (input$by_species) aes(color = Species),
          geom_point(),
          if (input$smooth) geom_smooth()
        )

      if (input$show_margins) {
        margin_type <- if (input$by_species) "density" else "histogram"
        p <- p |> ggExtra::ggMarginal(
          type = margin_type, margins = "both",
          size = 8, groupColour = input$by_species, groupFill = input$by_species
        )
      }

      p
    },
    res = 100
  )
}

shinyApp(ui, server)
