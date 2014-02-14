library(shiny)
library(shinyAce)
library(Gmisc, quietly=T)
library(RJSONIO)
source("R/dkdfinfo.r")
source("R/dkutils.r")
source("R/lib.r")

# to run
# shiny:::runApp("../Table1")
# shiny:::runApp("../Table1", launch.browser = rstudio::viewer)

data(iris)

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title.
  headerPanel(""),
  
  sidebarPanel(
    
    h2("Table1"),
    
    p("An interface to the Gmisc htmlTable function"),
    
    wellPanel(
      selectInput("dataset", "Dataframe:", choices = getDataFrames())
    ),
    
    wellPanel(
      p(helpText("Select the factor variable that will produce the columns, ",
                 "typically the Cases vs Controls ID var."
                 ),
      selectInput("colFactor","Columns Variable:", choices=getdfinfo(getDataFrames()[1])$factors$name, selected="", multiple=F)
      )),
    
    wellPanel(
      p(helpText("Select the numerics and factors to include ",
               "in the rows of the table.")),
      selectInput("numerics", "Numerics:", choices=getdfinfo(getDataFrames()[1])$numerics$name, selected="", multiple=T),
      selectInput("factors", "Factors:", choices=getdfinfo(getDataFrames()[1])$factors$name, selected="", multiple=T)
    ),
    
    div(class="accordion", id ="optionsAccordion", 
        div(class="accordion-group", id = "optionsAccordionGroup", 
            buildAccordion("Column Options", "coloptions", "", tagList(
                              checkboxInput("chkStatistics", "Show Statistics", F),
                              checkboxInput("chkTotals", "Show Total Column", T),
                              checkboxInput("chkNEJM", "NEJM Style n (%)", T),
                              checkboxInput("chkColN", "N= in column header", T),
                              p(),
                              spreadsheetInput("tblColOptions", rbind(c("","","")), colHeaders='["Name","Justify","Group"]')
                              ),
                           expanded=T),
            buildAccordion("Row Options", "rowoptions", "", tagList(
                              spreadsheetInput("tblRowOptions", rbind(c("","")), colHeaders='["Name","Digits"]')
#                               textInput("txtDigits", "Digits:")
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
    
    includeHTML("www/js/tools.js"),

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
