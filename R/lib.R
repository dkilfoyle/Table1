# shiny ui utiltieis

library(RJSONIO)

spreadsheetInput <- function(inputId = "exampleGrid", value, colHeaders="true") {
  
  json_content <- toJSON(value, collapse = "")
  
  dataTableDef <- sprintf('
    $(window).load(function(){
      var myData = %s;
      
      $("#%s").handsontable({
        data: myData,
        startRows: 5,
        startCols: 5,
        minSpareCols: 0,
        //always keep at least 1 spare row at the right
        minSpareRows: 0,
        //always keep at least 1 spare row at the bottom,
        rowHeaders: false,
        colHeaders: %s,
        contextMenu: true
      });
    });', json_content, inputId, colHeaders)

  tagList(
    singleton(tags$head(tags$script(src = "js/handsontable/jquery.handsontable.full.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shiny-handsontable.js", type='text/javascript'))),
    singleton(tags$head(tags$link(rel="stylesheet", type="text/css", href="js/handsontable/jquery.handsontable.full.css"))),
    
    tags$div(id=inputId, class="dataTable", type = "button"),  
    tags$script(type='text/javascript', dataTableDef)
  )
}

select2Input <- function(inputId, label, choices = NULL, selected = NULL, placeholder = "", ...) {

  tagList(
    
    singleton(tags$head(tags$link(href="js/select2/select2.css",rel="stylesheet",type="text/css"))),
    singleton(tags$head(tags$script(src="js/select2/select2.js"))),
    singleton(tags$head(tags$script(src="js/jquery-ui-1.10.3.custom.min.js"))),
    singleton(tags$head(tags$script(src="js/select2.sortable.js"))),
    
    selectInput(inputId, label, choices, selected, ...),
    tags$script(sprintf("$(function() { $('#%s').select2({width:'resolve', placeholder:'%s'}); $('#%s').select2Sortable(); })", inputId, placeholder, inputId))

  )
}

buildAccordion = function(label, name, dataparent, item, expanded=F) {
  inclass = ifelse(expanded, "in", "")
  tagList(
    div(class="accordion-heading", 
        HTML(paste('<a class="accordion-toggle" data-toggle="collapse" data-parent="', dataparent, '" href="#collapse',name,'">',label,'</a>', sep=""))
    ),
    
    div(id=paste("collapse",name,sep=""), class=paste("accordion-body collapse", inclass),
        div(class="accordion-inner", lapply(item, function(x) x))
    )
  )
}

disableControl <- function(id,session) {
  session$sendCustomMessage(type="jsCode",
                            list(code= paste("$('#",id,"').prop('disabled',true)",sep="")))
}

enableControl <- function(id,session) {
  session$sendCustomMessage(type="jsCode",
                            list(code= paste("$('#",id,"').prop('disabled',false)",sep="")))
}

jsCodeHandler = function() {
  tags$head(tags$script(HTML('
        Shiny.addCustomMessageHandler("jsCode",
          function(message) {
            console.log(message)
            eval(message.code);
          }
        );
      ')))
}

