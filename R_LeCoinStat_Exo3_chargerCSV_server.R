#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(DT)
# Define server logic required to draw a histogram
function(input, output, session) {
  
  modele_logistique <- readRDS("/BUREAU/1- STUDY/E-learning/R/model_logistique.rds") 
  
  data <- reactiveVal() # Pour stocker les données importées
  
  observeEvent(input$loadData, {
    req(input$fileInput) # S'assurer qu'un fichier est bien chargé
    df <- read.csv(input$fileInput$datapath) # Utilisation de ';' comme séparateur
    
    # Conversion de 'Pclass' et 'Sex' en facteurs
    df$Pclass <- as.factor(df$Pclass)
    df$Sex <- factor(df$Sex, levels = c("male", "female"))
    
    data(df)
    
    output$dataTable <- renderDT({
      req(data()) # S'assurer que les données sont disponibles
      data()
                                  },
     
      options = list(pageLength = 5)) # Limiter le nombre de lignes affichées
  })
  
  output$predictionsTable <- renderDT({
    req(data()) # S'assurer que les données sont disponibles et non vides
    
    if (nrow(data()) > 0) {
      
      model_logistique2 <- readRDS("/BUREAU/1- STUDY/E-learning/R/model_logistique.rds") # Ajustez le chemin selon votre configuration
      newData <- data()
      # Prédictions
      prob <- predict(model_logistique2, newdata = newData, type = "response")
      predictions <- ifelse(prob > 0.5, "Survived", "Did Not Survive")
      
      results <- cbind(newData, Predictions = predictions) # Ajouter les prédictions aux données
      
      return(results)
    } else {
      return(data.frame(Error = "Aucune donnée à afficher. Veuillez charger un fichier CSV."))
    }
  }, options = list(pageLength = 5))
  
}