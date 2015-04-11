source("R/table1.r")

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output, session) {
  
  colGroups <<- c()
  n.colGroups <<- c()
  
  # Return the requested dataset
  getSelectedDFName <- reactive({
    input$dataset
  })
  
  getSelectedDF <- reactive({
    eval(parse(text=input$dataset))
  })
  
  getDFInfo <- reactive({
    getdfinfo(input$dataset)
  })
  
  # use observe to connect a change in input$dataset to the select boxes
  observe({
    dfinfo = getDFInfo()
    
    # update colFactor
    updateSelectInput(session, "colFactor", choices=dfinfo$factors$name)
    # Update the field selects
    updateSelectInput(session, "numerics", choices=dfinfo$numerics$name)
    updateSelectInput(session, "factors", choices=dfinfo$factors$name)
    
  }, priority=1)
  
  # if the column factor selection is changed....
  observe({
    isolate({curdf = getSelectedDF()}) # use isolate to avoid circular reactivity
    colFactor = input$colFactor
    
    colOptions = rbind()
    for (x in levels(curdf[, colFactor])) {
      colOptions = rbind(colOptions, c(x, "c", colFactor))
    }
    
    session$sendInputMessage("tblColOptions", list(value=colOptions))
    
    if (length(levels(curdf[, colFactor]))>2)
      disableControl("chkStatistics", session)
    else
      enableControl("chkStatistics", session)

  })
  
  getSelectedFields = reactive({
    selectedFields = rbind()
    
    # first get the current selections from the handsontable
    if (!is.null(input$tblRowOptions))
      selectedFields = t(sapply(fromJSON(input$tblRowOptions),paste))
    
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
      colOptions = t(sapply(fromJSON(input$tblColOptions),paste)) 
    
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
    
    if (input$describeNumeric == "Mean")
    {
      mycontinuous_fn = describeMean
      mycontinuous_fns = "describeMean"
    }
    else
    {
      mycontinuous_fn = describeMedian
      mycontinuous_fns = "describeMedian"
    }
    
    css.class = paste0("gmisc_table", substr(input$radTableWidth,1,2))
    
    x = table1(curdf, colfactor, selectedFields, colOptions, 
               add_total_col = input$chkTotals,
               statistics = input$chkStatistics,
               NEJMstyle = input$chkNEJM,
               colN = input$chkColN,
               caption = input$txtCaption,
               pos.caption = input$txtCapLoc,
               tfoot = input$txtFooter, 
               continuous_fn = mycontinuous_fn,
               css.class = css.class
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
        pos.caption = input$txtCapLoc,
        tfoot = input$txtFooter,
        selectedFields = paste(deparse(selectedFields), collapse=""),
        colOptions = paste(deparse(colOptions), collapse=""),
        continuous_fn = mycontinuous_fns,
        colN = input$chkColN,
        css.class = css.class
      )
      updateAceEditor(session, "acer", value = whisker.render(template, whiskerdata), mode="markdown")
    })
    
    return(x)
  })
  
})