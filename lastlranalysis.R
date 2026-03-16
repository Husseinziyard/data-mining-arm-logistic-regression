# Allow file uploads up to 30 MB
options(shiny.maxRequestSize = 30*1024^2)

library(shiny)
library(tidyverse)
library(caret)
library(e1071)
library(pROC)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Diabetic Readmission Logistic Regression"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxInput("useLocal", "Use internal diabetic_data.csv file", value = TRUE),
      conditionalPanel(
        condition = "!input.useLocal",
        fileInput("file", "Upload CSV File", accept = ".csv")
      ),
      actionButton("run", "Run Logistic Regression")
    ),
    
    mainPanel(
      verbatimTextOutput("modelSummary"),
      tableOutput("confusionMatrix"),
      plotOutput("confusionPlot"),
      plotOutput("rocPlot")
    )
  )
)

server <- function(input, output) {
  data_input <- eventReactive(input$run, {
    # Load the dataset based on user's choice
    if (input$useLocal) {
      df <- read.csv("diabetic_data.csv", na.strings = "?")
    } else {
      req(input$file)
      df <- read.csv(input$file$datapath, na.strings = "?")
    }
    
    # Cleaning and preparation
    df <- df %>% select(-encounter_id, -patient_nbr, -weight, -payer_code, -medical_specialty)
    df$readmitted_binary <- ifelse(df$readmitted == "<30", 1, 0)
    df$readmitted <- NULL
    df[sapply(df, is.character)] <- lapply(df[sapply(df, is.character)], as.factor)
    df <- na.omit(df)
    df[] <- lapply(df, function(x) if (is.factor(x)) as.numeric(x) else x)
    df
  })
  
  model_result <- eventReactive(input$run, {
    data <- data_input()
    set.seed(123)
    idx <- createDataPartition(data$readmitted_binary, p = 0.7, list = FALSE)
    train <- data[idx, ]
    test <- data[-idx, ]
    
    model <- glm(readmitted_binary ~ ., data = train, family = "binomial")
    probs <- predict(model, test, type = "response")
    preds <- ifelse(probs > 0.5, 1, 0)
    
    list(
      model = model,
      test = test,
      preds = preds,
      probs = probs,
      conf = confusionMatrix(as.factor(preds), as.factor(test$readmitted_binary)),
      roc = roc(test$readmitted_binary, probs)
    )
  })
  
  output$modelSummary <- renderPrint({
    summary(model_result()$model)
  })
  
  output$confusionMatrix <- renderTable({
    as.data.frame(model_result()$conf$table)
  })
  
  output$confusionPlot <- renderPlot({
    cm_df <- as.data.frame(model_result()$conf$table)
    ggplot(cm_df, aes(x = Reference, y = Prediction, fill = Freq)) +
      geom_tile() +
      geom_text(aes(label = Freq), vjust = 1) +
      scale_fill_gradient(low = "white", high = "darkgreen") +
      labs(title = "Confusion Matrix", x = "Actual", y = "Predicted")
  })
  
  output$rocPlot <- renderPlot({
    plot(model_result()$roc, main = "ROC Curve", col = "blue")
  })
}

shinyApp(ui = ui, server = server)

