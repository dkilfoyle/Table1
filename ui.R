library(shiny)
library(shinyAce)
library(Gmisc)
source("R/dkdfinfo.r")
source("R/dkutils.r")

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
    
    div(class="accordion", id ="fieldsAccordion", 
        div(class="accordion-group", id = "fieldsAccordionGroup", 
            #buildAccordion("Numerics", selectInput("numerics", "", choices=getdfinfo(getDataFrames()[1])$numerics$name, selected="", multiple=T), expanded=T),
            #buildAccordion("Factors",  selectInput("factors", "", choices=getdfinfo(getDataFrames()[1])$factors$name, selected="", multiple=T), expanded=T),
            buildAccordion("Options", c(
                           tagList(checkboxInput("chkStatistics", "Show Statistics", F)),
                           tagList(checkboxInput("chkTotals", "Show Totals", T)),
                           tagList(textInput("txtCaption", "Caption")),
                           textInput("txtCapLoc", "Caption Location", "top"),
                           textInput("txtFooter", "Footer")),
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
