library(shiny)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output, session) {
  
  selectedFields <<- c()
  colGroups <<- c()
  n.colGroups <<- c()
  
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
    
    updateSelectInput(session, "colFactor", "", choices=dfinfo$factors$name, selected=dfinfo$factors$name[1])
    
    # Update the field selects
    updateSelectInput(session, "numerics", "", choices=dfinfo$numerics$name, selected="")
    updateSelectInput(session, "factors", "", choices=dfinfo$factors$name, selected="")
  })
  
  observe({
    colFactor = input$colFactor
    
    # assume we want a total column
    updateTextInput(session, "txtColGroup", label="Column Groups:", paste0('c("", "', colFactor, '")'))
    cgroupn = length(levels(getSelectedDF()[, colFactor]))
    updateTextInput(session, "txtColGroupN", label="Column Groups.n", paste0('c(1, ', cgroupn, ')'))
  })
  
  output$Table1 = renderText({
    
    # add new selections
    selectedFields <<- unique(c(selectedFields, input$numerics, input$factors)) 
    
    # remove unselections
    removedItem = which(!(selectedFields %in% c(input$numerics, input$factors)))
    if (length(removedItem)) selectedFields = selectedFields[-removedItem]
    
    if (length(selectedFields) == 0) 
      return("Select some numeric or factor fields from the selection boxs in the left sidebar.")
    
    colfactor = input$colFactor
    curdf = getSelectedDF()
    
    getT1Stat <- function(varname, digits=2){
      getDescriptionStatsBy(curdf[, varname], curdf[, colfactor], show_all_values=TRUE, hrzl_prop=T, html=TRUE, 
                            add_total_col=input$chkTotals,
                            statistics=input$chkStatistics, 
                            NEJMstyle = input$chkNEJM,
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
    
    # build N= col headings
    if (input$chkColN) 
      headings = sapply(colnames(output_data), function(x) {
        if (x=="Total")
          paste0(x, " (n=", nrow(curdf), ")")
        else
          paste0(x, " (n=", sum(curdf[, colfactor]==x), ")")
        })
    else
      headings = colnames(output_data)
    
    
    if (input$chkColGroups) {
      cgroup = eval(parse(text=input$txtColGroup))
      n.cgroup = eval(parse(text=input$txtColGroupN))
    }
    else
    {
      cgroup = NULL
      n.cgroup = NULL
    }
    
      x = htmlTable(output_data, align="rrrr",
              rgroup=rgroup, n.rgroup=n.rgroup, 
              rgroupCSSseparator="",
              cgroup = cgroup,
              n.cgroup = n.cgroup,
              headings=headings,
              rowlabel="", 
              caption=input$txtCaption, 
              caption.loc = input$txtCapLoc,
              tfoot=input$txtFooter, 
              ctable=TRUE,
              output=F)
    
    return(x)
  })
  
})