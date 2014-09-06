library(shiny)
library(shinyAce)
library(whisker)
source("R/dkdfinfo.r")
source("R/lib.r")
source("R/melanoma.r")
source("R/table1.r")

# to run
# shiny:::runApp()
# shiny:::runApp("../Table1", launch.browser = rstudio::viewer)

data(iris)

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title.
  headerPanel(""),
  
  sidebarPanel(
    
    includeScript("www/js/jquery-ui-1.10.3.custom.min.js"),
    jsCodeHandler(),
    includeCSS("www/table1.css"),
    
    h2("Table1"),
    
    p("An interface to the Gmisc htmlTable function"),
    
    wellPanel(
      selectInput("dataset", "Dataframe:", choices = getDataFrames())
    ),
    
    wellPanel(
      p(helpText("Select the factor variable that will produce the columns, ",
                 "typically the Cases vs Controls ID var."
                 ),
      selectInput("colFactor","Columns Variable:", choices=getdfinfo(getDataFrames()[1])$factors$name, multiple=F)
      )),
    
    wellPanel(
      p(helpText("Select the numerics and factors to include ",
               "in the rows of the table.")),
      selectizeInput("numerics", "Numerics:", choices=getdfinfo(getDataFrames()[1])$numerics$name, selected="", multiple=T, 
                     options=list(placeholder="Select numeric(s)", dropdownParent = "body", plugins=list(remove_button="", drag_drop=""))),
      selectizeInput("factors", "Factors:", choices=getdfinfo(getDataFrames()[1])$factors$name, selected="", multiple=T, 
                     options=list(placeholder="Select factor(s)", dropdownParent = "body", plugins=list(remove_button="", drag_drop="")))
    ),
    
    div(class="accordion", id ="optionsAccordion", 
        div(class="accordion-group", id = "optionsAccordionGroup", 
            buildAccordion("Column Options", "coloptions", "", tagList(
                              checkboxInput("chkStatistics", "Show Statistics", F),
                              checkboxInput("chkTotals", "Show Total Column", T),
                              checkboxInput("chkNEJM", "NEJM Style n (%)", T),
                              checkboxInput("chkColN", "N= in column header", T),
                              p(),
                              spreadsheetInput("tblColOptions", rbind(c("","","")), 
                                               colHeaders='["Name","Justify","Group"]',
                                               options='columns: [ {}, {type: "dropdown", source: ["c","l","r"] }, {} ]')
                              ),
                           expanded=T),
            buildAccordion("Row Options", "rowoptions", "", tagList(
                              spreadsheetInput("tblRowOptions", rbind(c("","")), colHeaders='["Name","Digits"]')
                            ),
                           expanded=F),
            buildAccordion("Table Options", "tableoptoins", "", tagList(
                              textInput("txtCaption", "Caption:"),
                              textInput("txtCapLoc", "Caption Location:", "top"),
                              textInput("txtFooter", "Footer:")),
                           expanded=F
                           )
        )
    )
  
  ), # end sidebarpanel

  mainPanel(
    
    tabsetPanel(id="mainPanelTabset",
      tabPanel("Table", 
              htmlOutput("Table1")
      ),
      tabPanel("Source",
               aceEditor("acer", mode="r")
      )
    )
  )
))
