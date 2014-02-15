library(shiny)
library(whisker)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output, session) {
  
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
  observe({
    dfinfo = getdfinfo(input$dataset)
    
    updateSelectInput(session, "colFactor", "", choices=dfinfo$factors$name, selected=dfinfo$factors$name[1])
    
    # Update the field selects
    updateSelectInput(session, "numerics", "", choices=dfinfo$numerics$name, selected="")
    updateSelectInput(session, "factors", "", choices=dfinfo$factors$name, selected="")
  
  })
  
  # if the column factor selection is changed....
  observe({
    colFactor = input$colFactor
    
    colOptions = rbind()
    for (x in levels(getSelectedDF()[, colFactor])) {
      colOptions = rbind(colOptions, c(x, "c", ""))
    }
    
    session$sendInputMessage("tblColOptions", list(value=colOptions))
  })
  
  getSelectedFields = reactive({
    selectedFields = rbind()
    
    # first get the current selections from the handsontable
    if (!is.null(input$tblRowOptions))
      for (x in fromJSON(input$tblRowOptions)) selectedFields = rbind(selectedFields, x, deparse.level=0)
    
    # add new selections from the field lists
    newSelection = which(!(c(input$numerics, input$factors) %in% selectedFields[,1]))
    if (length(newSelection))
      selectedFields = rbind(selectedFields, c(c(input$numerics, input$factors)[newSelection], "2"), deparse.level=0)
      
    # remove unselections
    removedItem = which(!(selectedFields[,1] %in% c(input$numerics, input$factors)))
    if (length(removedItem))
      selectedFields = rbind(selectedFields[-removedItem, ])
    
    # update tblRowOptions
    if (length(selectedFields) == 0) {
      session$sendInputMessage("tblRowOptions", list(value=rbind(c("",""))))
      selectedFields = rbind()
    }
    else
      session$sendInputMessage("tblRowOptions", list(value=selectedFields))

    return(selectedFields)
  })
  
  getColOptions = reactive({
    colOptions = rbind()
    
    # first get the current optionsselections from the handsontable
    if (!is.null(input$tblColOptions))
      for (x in fromJSON(input$tblColOptions)) colOptions = rbind(colOptions, x, deparse.level=0)
    
    return(colOptions)
    
  })
  
  output$Table1 = renderText({
    
    selectedFields = getSelectedFields()
    rownames(selectedFields) = NULL
    colOptions = getColOptions()
    
    if (is.null(selectedFields)) 
      return("Select some numeric or factor fields from the selection boxs in the left sidebar.")
    
    colfactor = input$colFactor
    curdf = getSelectedDF()
    
    x = table1(curdf, colfactor, selectedFields, colOptions, 
               add_total_col = input$chkTotals,
               statistics = input$chkStatistics,
               NEJMstyle = input$chkNEJM,
               colN = input$chkColN,
               caption = input$txtCaption,
               caption.loc = input$txtCapLoc,
               tfoot = input$txtFooter
               )
    
    observe({
      # hmm, ugly hack but works - a reactive dependency on selectedFields and coloptions
      # this allows to update source if fields changed even when output$table1 not visible
      selectedFields = getSelectedFields()
      colOptions = getColOptions()
      template = paste(readLines("table1.template"), collapse="\n")
      whiskerdata = list(
        add_total_col = input$chkTotals,
        statistics = input$chkStatistics,
        NEJMstyle = input$chkNEJM,
        curdf = input$dataset,
        colfactor = input$colFactor,
        caption = input$txtCaption,
        captionloc = input$txtCapLoc,
        tfoot = input$txtFooter,
        selectedFields = paste(deparse(selectedFields), collapse=""),
        colOptions = paste(deparse(colOptions), collapse=""),
        colN = input$chkColN
      )
      updateAceEditor(session, "acer", value = whisker.render(template, whiskerdata), mode="r")
    })
    
    return(x)
  })
  
})