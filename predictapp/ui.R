library(shiny)
library(dplyr)
shinyUI(pageWithSidebar(
        headerPanel("Word Prediction Application"),
        sidebarPanel(
                textInput(inputId="sentence",label = "Type at least two words and we'll try to predict your next word",
                          value = "write at least 2 words"),
                actionButton("go",label="Predict")
        ),
        mainPanel(
                h3('Top three predicted words are:'),
                verbatimTextOutput("pred1"),
                verbatimTextOutput("pred2"),
                verbatimTextOutput("pred3"),
        )
))

