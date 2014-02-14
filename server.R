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
      for (x in fromJSON(input$tblRowOptions)) selectedFields = rbind(selectedFields, x)
    
    # add new selections from the field lists
    newSelection = which(!(c(input$numerics, input$factors) %in% selectedFields[,1]))
    if (length(newSelection))
      selectedFields = rbind(selectedFields, c(c(input$numerics, input$factors)[newSelection], "2"))
      
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
      for (x in fromJSON(input$tblColOptions)) colOptions = rbind(colOptions, x)
    
    return(colOptions)
    
  })
  
  output$Table1 = renderText({
    
    selectedFields = getSelectedFields()
    colOptions = getColOptions()
    
    if (is.null(selectedFields)) 
      return("Select some numeric or factor fields from the selection boxs in the left sidebar.")
    
    colfactor = input$colFactor
    curdf = getSelectedDF()
    
    getT1Stat <- function(varname, digits=2){
      getDescriptionStatsBy(curdf[, varname], curdf[, colfactor], show_all_values=TRUE, hrzl_prop=T, html=TRUE, 
                            add_total_col=input$chkTotals, statistics=input$chkStatistics, 
                            NEJMstyle = input$chkNEJM, digits=digits)
    }
    
    # Get the basic stats and store in a list
    table_data <- list()
    for (i in 1:nrow(selectedFields)) {
      table_data[[ selectedFields[i,1] ]] = getT1Stat(selectedFields[i,1], as.integer(selectedFields[i,2]))
    }
    
    # Now merge everything into a matrix
    # and create the rgroup & n.rgroup variabels
    rgroup <- c()
    n.rgroup <- c()
    output_data <- NULL
    for (varlabel in names(table_data)){
      output_data <- rbind(output_data, table_data[[varlabel]])
      rgroup <- c(rgroup, varlabel)
      n.rgroup <- c(n.rgroup, nrow(table_data[[varlabel]]))
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
    
    # build cgroup from colOptions
    cgroup=c("")
    n.cgroup=c(0)
    if (input$chkTotals) n.cgroup=c(1)

    for (i in 1:nrow(colOptions)) {
      if (colOptions[i,3] == cgroup[length(cgroup)]) # if curgroup same as the last one 
        n.cgroup[length(n.cgroup)] = n.cgroup[length(n.cgroup)]+1
      else {
        n.cgroup = c(n.cgroup, 1)
        cgroup = c(cgroup, colOptions[i,3])
      }
    }
    
    if (all(cgroup==c(""))) cgroup=NULL
    
    # build column alignment from colOptions
    if (input$chkTotals) align="c" else align=""
    for (i in 1:nrow(colOptions))
      align = paste0(align, colOptions[i,2])
    
      x = htmlTable(output_data, align=align,
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
    
    template = paste(readLines("table1.template"), collapse="\n")
    whiskerdata = list(
      chkTotals = input$chkTotals,
      chkStatistics = input$chkStatistics,
      chkNEJM = input$chkNEJM,
      curdf = input$dataset,
      colfactor = input$colFactor,
      rgroup = deparse(rgroup),
      nrgroup = deparse(n.rgroup),
      headings = paste(deparse(as.vector(headings)), collapse=""),
      align = deparse(align),
      caption = input$txtCaption,
      caption.loc = input$txtCapLoc,
      tfoot = input$txtFooter,
      cgroup = deparse(cgroup),
      ncgroup = deparse(n.cgroup),
      selectedFields = list()
      )
    
    observe({
      updateAceEditor(session, "acer", value = whisker.render(template, whiskerdata), mode="r")
    })
    
    return(x)
  })
  
})