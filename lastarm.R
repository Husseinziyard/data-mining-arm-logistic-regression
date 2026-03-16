# app.R
options(shiny.maxRequestSize = 30*1024^2)


library(shiny)
library(readxl)
library(arules)
library(arulesViz)
library(tidyverse)

ui <- fluidPage(
  titlePanel("Association Rule Mining - Online Retail"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload Excel File", accept = ".xlsx"),
      numericInput("supp", "Support (min):", value = 0.01, step = 0.01),
      numericInput("conf", "Confidence (min):", value = 0.5, step = 0.05),
      selectInput("plotType", "Plot Type:",
                  choices = c("Scatterplot" = "scatterplot", 
                              "Grouped" = "grouped", 
                              "Graph" = "graph")),
      actionButton("run", "Run Association Rule Mining")
    ),
    
    mainPanel(
      h4("Top 10 Association Rules"),
      tableOutput("rulesTable"),
      plotOutput("rulesPlot")
    )
  )
)

server <- function(input, output) {
  observeEvent(input$run, {
    req(input$file)
    
    # Read and clean data
    data <- read_excel(input$file$datapath) %>%
      drop_na() %>%
      filter(!grepl("^C", InvoiceNo)) %>%
      select(InvoiceNo, Description, Quantity) %>%
      mutate(InvoiceNo = as.factor(InvoiceNo),
             Description = as.factor(Description)) %>%
      group_by(InvoiceNo, Description) %>%
      summarise(Quantity = sum(Quantity), .groups = "drop") %>%
      mutate(Value = 1) %>%
      pivot_wider(names_from = Description, values_from = Value, values_fill = 0)
    
    # Convert to transaction format
    transaction_matrix <- as.matrix(data[,-1])
    rownames(transaction_matrix) <- data$InvoiceNo
    transactions <- as(transaction_matrix, "transactions")
    
    # Mine rules
    rules <- apriori(transactions, 
                     parameter = list(supp = input$supp, 
                                      conf = input$conf, 
                                      minlen = 2))
    
    top_rules <- head(sort(rules, by = "lift"), 10)
    
    # Output table
    output$rulesTable <- renderTable({
      inspect(top_rules) %>%
        as.data.frame() %>%
        select(lhs, rhs, support, confidence, lift)
    })
    
    # Output plot
    output$rulesPlot <- renderPlot({
      plot(top_rules, method = input$plotType, engine = ifelse(input$plotType == "graph", "igraph", "default"))
    })
  })
}

shinyApp(ui = ui, server = server)
