library(shiny)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output, session) {
  
  # Return the requested dataset
  getSelectedDFName <- reactive({
    input$dataset
  })
  
  getSelectedDF <- reactive({
    eval(parse(text=getSelectedDFName()))
  })
  
  getDFInfo <- reactive({
    getdfinfo(input$dataset)
  })
  
  # use observe to connect a change in input$dataset to the select boxes
  # TODO: is this the appropriate "reactive" way of doing this?
  observe({
    dfinfo = getdfinfo(input$dataset)
    
    # Update the field selects
    updateSelectInput(session, "numerics", "", choices=dfinfo$numerics$name, selected="")
    updateSelectInput(session, "factors", "", choices=dfinfo$factors$name, selected="")
  })
  
  output$Table1 = renderText({
  
    numerics = input$numerics 
    factors = input$factors
          
    return(numerics)
    
  })
  
})