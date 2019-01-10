# ---
# title: "Data Science Capstone: Final Project"
# author: "Isis Ibarra"
# date: "08/01/2019"
# output: R User Interface
# ---

# 1. Load libraries
library(shiny)
library(dplyr)
library(shinythemes)

# Define UI for application 
shinyUI(navbarPage("Data Science Capstone Project", theme = shinytheme("united"),
                   tabPanel("Introduction"),
                   tabPanel("Prediction",
     
                            mainPanel(
                              h2("Word Prediction:"),
                              textInput("string_input","",placeholder="Enter text here")
                            ),
                            mainPanel(
                              h4("Predicted words:"),
                              div(id="predButtons",
                                  uiOutput("predictionButton_1"),
                                  uiOutput("predictionButton_2"),
                                  uiOutput("predictionButton_3")
                              ),
                              div(id="top_prediction",
                                  h4("Top prediction:"),
                                  textOutput("best_prediction")
                              )
                            )
                   ),
                   tabPanel("Resources")
))

