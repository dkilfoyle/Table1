library(shiny)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output, session) {
  
  selectedFields <<- c()
  
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
    
    # add new selections
    selectedFields <<- unique(c(selectedFields, input$numerics, input$factors)) #, unique(c(selectedFields, input$factors)))
    
    # remove unselections
    removedItem = which(!(selectedFields %in% c(input$numerics, input$factors)))
    if (length(removedItem)) selectedFields = selectedFields[-removedItem]
    
    if (length(selectedFields) == 0) return("Select some fields")
    
    colfactor = input$colFactor
    
    getT1Stat <- function(varname, digits=2){
      getDescriptionStatsBy(getSelectedDF()[, varname], 
                            getSelectedDF()[, colfactor], 
                            add_total_col=TRUE,
                            show_all_values=TRUE, 
                            hrzl_prop=T,
                            statistics=FALSE, 
                            html=TRUE, 
                            digits=digits)
    }
    
    # Get the basic stats and store in a list
    table_data <- list()
    for (myvar in selectedFields) {
      table_data[[myvar]] = getT1Stat(myvar)
    }
    
    # Now merge everything into a matrix
    # and create the rgroup & n.rgroup variabels
    rgroup <- c()
    n.rgroup <- c()
    output_data <- NULL
    for (varlabel in names(table_data)){
      output_data <- rbind(output_data, 
                           table_data[[varlabel]])
      rgroup <- c(rgroup, 
                  varlabel)
      n.rgroup <- c(n.rgroup, 
                    nrow(table_data[[varlabel]]))
    }
    
    x = htmlTable(output_data, align="rrrr",
              rgroup=rgroup, n.rgroup=n.rgroup, 
              rgroupCSSseparator="", 
              #cgroup = cgroup,
              #n.cgroup = n.cgroup,
              rowlabel="", 
              caption="Caption", 
              tfoot="Footer", 
              ctable=TRUE,
              output=F)
    
    return(x)
  })
  
})