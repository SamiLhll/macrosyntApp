#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(macrosyntR)
library(ggplot2)
library(shinycssloaders)

# Define UI for data upload app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("macrosyntApp"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      helpText("Draw ordered Oxford grids using macrosyntR"),
      helpText("Usage : Browse to select the genomic coordinates of orthologs on both species (BED format) and a table of ortholog. Submit and wait a few seconds"),
      
      # Input: Select a file ----
      fileInput("file1", "Choose 1st bed File",
                multiple = FALSE,
                accept = c(".bed")),
      fileInput("file2", "Choose 2nd bed File",
                multiple = FALSE,
                accept = c(".bed")),
      fileInput("file3", "Choose table of orthologs",
                multiple = FALSE,
                accept = c(".tab")),
      actionButton("do","Draw")
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      plotOutput("macrosyntR_output")
      # uiOutput("DownloadData")
      # downloadButton("DownloadData","Download")
      
      
      
      # Output: Data file ----
      
      
      
    )
    
  )
)

options(shiny.maxRequestSize=30*1024^2)
# Define server logic to read selected file ----
server <- function(input, output,session) {
  
  # Copy data to the local folder
  observeEvent(input$do, {
    
    # The whole process can be called only if the two fasta files were successfully uploaded :
    req(input$file1, input$file2,input$file3)
    
    # read 1st fasta and write to the data folder :
    my_orthologs <- macrosyntR::load_orthologs(orthologs_table = input$file3$datapath,
                                   sp1_bed = input$file1$datapath,
                                   sp2_bed = input$file2$datapath)
    
  
    # display amount of orthologs found and download button :
    output$macrosyntR_output <- renderPlot({ p <- macrosyntR::plot_oxford_grid(my_orthologs)
    print(p)})
    
    # output$DownloadData <- renderUI({downloadButton("Downloadplot","Download") })
    # 
    # output$Downloadplot <- downloadHandler(
    #   filename = function() { paste(input$plotname, '.png', sep='') },
    #   content = function(file) {
    #     device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
    #     ggsave(file, plot = p, device = device)
    #   })
  })
  # session$onSessionEnded(function() { unlink(c("sessionFolder/file1.fa",
  #                                              "sessionFolder/file2.fa",
  #                                              "sessionFolder/reciprocal_best_hits.tab",
  #                                              "sessionFolder/p1_p2","sessionFolder/p2.dmnd","sessionFolder/p2_p1.s",
  #                                              "sessionFolder/p1.dmnd","sessionFolder/p1_p2.s","sessionFolder/p2_p1") )})
}

# Create Shiny app ----
shinyApp(ui, server)