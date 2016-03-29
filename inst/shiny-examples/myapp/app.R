ui <- fluidPage(

  plotOutput(outputId = "myeem", width = "550px", height = "550px"),

  sliderInput("range",
              label = "EEM index",
              min = 1, max = 6, value = 1)

)

server <- function(input, output) {

  folder <- system.file("inst/extdata/cary", package = "eemR")
  eems <- eem_read(folder, recursive = TRUE) %>%
    eem_remove_scattering(type = "raman", order = 1) %>%
    eem_remove_scattering(type = "rayleigh", order = 1)

  output$myeem <- renderPlot({
    plot(eems, which = input$range)
    #hist(rnorm(input$range))
  })
}

shinyApp(ui, server)
