library(RJSONIO)


# example from increment button
# incrementButton <- function(inputId, value = 0) {
#   tagList(
#     singleton(tags$head(tags$script(src = "increment.js"))),
#     tags$button(id = inputId,
#                 class = "increment btn",
#                 type = "button",
#                 as.character(value))
#   )
# }

spreadsheetInput <- function(inputId = "exampleGrid", value) {
  
  json_content <- toJSON(value, collapse = "")
  
  dataTableDef <- sprintf('
    $(window).load(function(){
      var myData = %s;
      
      $("#%s").handsontable({
        data: myData,
        startRows: 5,
        startCols: 5,
        minSpareCols: 1,
        //always keep at least 1 spare row at the right
        minSpareRows: 1,
        //always keep at least 1 spare row at the bottom,
        rowHeaders: true,
        colHeaders: true,
        contextMenu: true
      });
    });', json_content, inputId)

  tagList(
    singleton(tags$head(tags$script(src = "js/handsontable/jquery.handsontable.full.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shiny-handsontable.js", type='text/javascript'))),
    singleton(tags$head(tags$link(rel="stylesheet", type="text/css", href="js/handsontable/jquery.handsontable.full.css"))),
    
    tags$div(id=inputId, class="dataTable", type = "button"),  
    tags$script(type='text/javascript', dataTableDef)
  )
}
