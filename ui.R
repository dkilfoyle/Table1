library(shiny)
library(shinyAce)
library(Gmisc)
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
                              checkboxInput("chkNEJM", "NEJM Style", T),
                              checkboxInput("chkColN", "Column N=", T),
                              checkboxInput("chkColGroups", "Use Column Groups", F),
                              spreadsheetInput("gridTest", data.frame(x=c(1,2,3,4))),
                              p(),
                              helpText("Enter column group titles in the textbox below. 
                                       Use empty string for no Column Group. 
                                       Specify how many columns each title spans in the Column Groups.n text box
                                       Don't forget to account for the total column if present."),
                              textInput("txtColGroup", "Column Group:"),
                              textInput("txtColGroupN", "Column Group.n:")),
                           expanded=F),
            buildAccordion("Row Options", "rowoptions", "", tagList(
                              textInput("txtDigits", "Digits:")),
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
