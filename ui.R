## This is the user interface script for the energy profile application
## Users need to input two values: 
## 1) a category of data of choice (select input)
## 2) a range of years of interest (slider input)

library(shiny)

shinyUI(fluidPage(
  titlePanel("US Annual Energy Profile"),
  sidebarLayout(
    sidebarPanel(
      helpText("US Energy Information Administration (EIA) publishes annual and monthly energy data from different sectors.
               Use this app to create figures of summary data of total energy with annual data from 1949 to 2014."),
      selectInput(inputId = "category", label = "Choose a category of data", choices = c("energy overview",
                                                                                         "energy production by source", 
                                                                                         "energy consumption by source", 
                                                                                         "energy imports by source",
                                                                                         "energy exports by source")),
      sliderInput(inputId = "range", label = "Year range of interest", min = 1949, max = 2014, step = 1, value = c(1949, 2014)),
      submitButton(text = "Submit", icon = NULL, width = NULL),
      br(),
      p("Data Source:", a("US EIA", href = "https://www.eia.gov/totalenergy/data/annual/index.cfm"))
      
    ),
    mainPanel(
      plotOutput("figure")
    )
    
  )
)
  
)