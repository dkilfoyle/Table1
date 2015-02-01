# shiny ui utiltieis

library(RJSONIO)

spreadsheetInput <- function(inputId = "exampleGrid", value, colHeaders="true", options="") {
  
  json_content <- toJSON(value, collapse = "")
  
  dataTableDef <- sprintf('
    $(window).load(function(){
      var myData = %s;
      
      $("#%s").handsontable({
        data: myData,
        startRows: 5,
        startCols: 5,
        minSpareCols: 0,
        minSpareRows: 0,
        rowHeaders: false,
        colHeaders: %s,
        contextMenu: true,
        %s
      });
    });', json_content, inputId, colHeaders, options)

  tagList(
    singleton(tags$head(tags$script(src = "js/handsontable/jquery.handsontable.full.js", type='text/javascript'))),
    singleton(tags$head(tags$script(src = "js/shiny-handsontable.js", type='text/javascript'))),
    singleton(tags$head(tags$link(rel="stylesheet", type="text/css", href="js/handsontable/jquery.handsontable.full.css"))),
    
    tags$div(id=inputId, class="dataTable"), #type = "button"),  
    tags$script(type='text/javascript', dataTableDef)
  )
}

accordion = function(name, ...) {
  div(class="panel-group", id = name, role="tablist", ...)
}

# accordionPanel = function(title, ..., expanded=F) {
#   inclass = ifelse(expanded, "in", "")
#   myitemid = paste0("collapse", make.names(title))
#   
#   div(class="panel panel-default", 
#     div(class="panel-heading", role="tab",
#       h4(class="panel-title", 
#         HTML(paste('<a class="collapsed" data-toggle="collapse" href="#', myitemid, '">', title,'</a>', sep=""))
#       )
#     ), # panel-heading
#     div(id = myitemid, class=paste("panel-collapse collapse", inclass), role="tabpanel",
#       div(class="panel-body", ...)
#     ) # panel-collapse
#   )
# }

accordionPanel = function(title, ..., dataparent, expanded=F) {
  inclass = ifelse(expanded, "in", "")
  mydataparent = ifelse(missing(dataparent), "", paste0('data-parent="#', dataparent, '"'))
  myitemid = paste0("collapse", make.names(title))
  
  div(class="panel panel-default", 
    div(class="panel-heading", role="tab",
      h4(class="panel-title", 
        #a(datatoggle="collapse", dataparent=mydataparent, href=paste0("#", myitemid), title)
        HTML(paste('<a class="collapsed" data-toggle="collapse" ', mydataparent, ' href="#', myitemid, '">', title,'</a>', sep=""))
      )
    ), # panel-heading
    div(id = myitemid, class=paste("panel-collapse collapse", inclass), role="tabpanel",
      div(class="panel-body", ...)
    ) # panel-collapse
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

