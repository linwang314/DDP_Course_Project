## This is the server script for the energy profile application.
## It realizes the following objectives:
## 1) read raw data
## 2) process raw data into clean and relevant data for app use
## 3) create a energy vs. time line plot based on user input 

library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)


## Read raw data (need to change to the directory that contains both data and scripts)
## Path to directory should not contain any space in order to publish on ShinyApp
overview <- read.csv("MER_T01_01.csv")
production <- read.csv("MER_T01_02.csv", na.strings = "Not Available")
consumption <- read.csv("MER_T01_03.csv", na.strings = "Not Available")
import <- read.csv("MER_T01_04A.csv", na.strings = "Not Available")
export <- read.csv("MER_T01_04B.csv", na.strings = "Not Available")

## Subset relevant data 
overview <- filter(overview, Description %in% c("Total Primary Energy Production", "Total Primary Energy Consumption",
                                                "Primary Energy Imports", "Primary Energy Exports"))
production <- filter(production, Description %in% c("Biomass Energy Production", "Coal Production", "Crude Oil Production",
                                                    "Geothermal Energy Production", "Hydroelectric Power Production",
                                                    "Natural Gas (Dry) Production", "Natural Gas Plant Liquids Production",
                                                    "Nuclear Electric Power Production", "Solar/PV Energy Production",
                                                    "Wind Energy Production"))
import <- filter(import, !Description == "Total Primary Energy Imports")
export <- filter(export, !Description %in% c("Total Energy Exports", "Total Energy Net Imports"))

## Creat a list with all data frame so that lapply() can be used for convenient data processing and transformation
data <- list(overview = overview, production = production, consumption = consumption, import = import, export = export)

## Create a function for data processing and transformation
records <- function(x) {
  x <- x %>%
    separate(YYYYMM, c("year", "month"), 4)  %>%
    select(year, month, Description, Value)  %>%
    filter(month == "13") 
  x$year <- as.numeric(x$year)
  return(x)
}
## subdata are what needed for web application
subdata <- lapply(data, records)


shinyServer(function(input, output){
  output$figure <- renderPlot({
      
      ## switch() changes input into corresponding data frame
      dataforplot <- switch(input$category,
                        "energy overview" = subdata$overview,
                        "energy production by source" = subdata$production,
                        "energy consumption by source" = subdata$consumption,
                        "energy imports by source" = subdata$import,
                        "energy exports by source" = subdata$export)
      
      ## ggplot() creats a line plot, and x-axis limits are used to display time ranges of the user's choice      
      ggplot(dataforplot, aes(x = year, y = Value, color = Description)) + geom_line() +
        labs(x = "Year", y = "Quadrillion Btu") + theme(legend.position = "bottom") +
        scale_x_continuous(limits = c(input$range[1], input$range[2]))
    })
  
  })
  