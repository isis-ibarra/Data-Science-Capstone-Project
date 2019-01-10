# ---
# title: "Data Science Capstone: Final Project"
# author: "Isis Ibarra"
# date: "08/01/2019"
# output: R Server
# ---

# 1. Load libraries
suppressWarnings(library(shiny))
suppressWarnings(library(dplyr))
suppressWarnings(library(tm))

# 4. Functions
# 4.1 Cleaning input
cleanInput <- function(str, badWords) {
  graphToSpace <- function(x) {
    x <- gsub("[^[:graph:]]", " ", x)
    }
  str <- str %>%
    graphToSpace %>%
    tolower %>% # Transfrom to lowercase
    removeNumbers %>% # Remove nummbers
    removePunctuation %>% # Remove punctuation
    stripWhitespace %>% # Remove white spaces
    stemDocument %>% # Stem words
    removeWords(badWords) %>% # Remove bad words
    removeConfounders %>% # Remove cofunders
    removeWords(letters[!letters %in% c("a","i")])
    
  str
}

removeConfounders <- function(x) {
  x <- gsub("-", " ", x)
  x <- gsub(":", " ", x)
  x <- gsub(" -", " ", x)
  x <- gsub("- ", " ", x)
  x <- gsub(";", " ", x)
  x <- gsub("won't", "will not", x)
  x <- gsub("can't", "cannot", x)
  x <- gsub("'re", " are", x)
  x <- gsub("'ve", " have", x)
  x <- gsub("what's", "what is", x)
  x <- gsub("n't", " not", x)
  x <- gsub("'d", " would", x)
  x <- gsub("'ll", " will", x)
  x <- gsub("'m", " am", x)
}

# 4.2 Prediction model 
get_wordcount <- function(str){
  wordcount <- length(unlist(strsplit(str," ")))
  wordcount
}

predict_quadgram <- function(str, quadgrams) {
  if(get_wordcount(str) >= 3) {
    new_str <- paste(tail(unlist(strsplit(str," ")), 3))
    ret_val <- as.character(quadgrams[(quadgrams$unigram == new_str[1] & 
                                         quadgrams$bigram == new_str[2] &
                                         quadgrams$trigram == new_str[3]), ][, 4])
    ret_val[1:3]
  }
  else {NA}
}

predict_trigram <- function(str, trigrams) {
  if(get_wordcount(str) >= 2) {
    new_str <- paste(tail(unlist(strsplit(str, " ")), 2))
    ret_val <- as.character(trigrams[(trigrams$unigram == new_str[1] &
                                        trigrams$bigram == new_str[2]), ][, 3])
    ret_val[1:3]
  }
  else {NA}
}

predict_bigram <- function(str, bigrams) {
  if(get_wordcount(str) >= 1) {
    new_str <- paste(tail(unlist(strsplit(str, " ")), 1))
    ret_val <- as.character(bigrams[(bigrams$unigram == new_str[1]), ][, 2])
    ret_val[1:3]
  }
  else {NA}
}

predict <- function(str, bigrams, trigrams, quadgrams, badWords) {
  cleanInput(str, badWords)
  predictions <- character(0)
  predictions <- c(predictions, predict_quadgram(str, quadgrams))
  predictions <- c(predictions, predict_trigram(str, trigrams))
  predictions <- c(predictions, predict_bigram(str, bigrams))
  predictions <- unique(predictions)
  predictions[!is.na(predictions)][1:3]
}

# 5. Define server logic 
shinyServer(function(input, output, session) {
  # 5.1. Load the required n-grams
  bigrams <- readRDS("bigrams.RData");
  trigrams <- readRDS("trigrams.RData");
  quadgrams <- readRDS("quadgrams.RData"); 
  
  # 5.2. Load English bad words
  # This document was downloaded from Free Web Headers
  # https://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
  badWords <- readLines("bad_words.txt");
  
  userPrediction <- reactive({predict(input$userInput, bigrams, trigrams, quadgrams, badWords)})
  output$best_prediction <- renderText({
    userPrediction()[1]
  })
  
# 5.1 Prediction buttons
  output$predictionButton_1 <- renderUI({
    actionButton("button1", label = userPrediction()[1])
  })
  output$predictionButton_2 <- renderUI({
    actionButton("button2", label = userPrediction()[2])
  })
  output$predictionButton_3 <- renderUI({
    actionButton("button3", label = userPrediction()[3])
  })

# 5.2 Predition events
  observeEvent(input$button1, {
    if(input$userInput != ""){
      new_input <- paste(input$userInput, userPrediction()[1])
    }
    else {
      new_input <- userPrediction()[1]
    }
    updateTextInput(session, "userInput", value = new_input)
  })
  observeEvent(input$button2, {
    if(input$userInput != ""){
      new_input <- paste(input$userInput, userPrediction()[2])
    }
    else {
      new_input <- userPrediction()[2]
    }
    updateTextInput(session, "userInput", value = new_input)
  })
  observeEvent(input$button3, {
    if(input$userInput != ""){
      new_input <- paste(input$userInput, userPrediction()[3])
    }
    else {
      new_input <- userPrediction()[3]
    }
    updateTextInput(session, "userInput", value = new_input)
  })
})
