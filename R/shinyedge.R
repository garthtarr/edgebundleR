#' Shiny interface to the edgebundle function
#'
#' Opens a shiny GUI to facilitate interaction with the edgebundle function
#'
#' @param x an appropriately structured JSON file (see vignette for details) or a
#'   square symmetric matrix (e.g. correlation matrix) or an igraph object.
#'
#' @import shiny
#'
#' @export
shinyedge = function(x){

  if((typeof(x)=="character")){
    type='fname'
  } else if (class(x)=="igraph"){
    type='igraph'
  } else {
    type='symmat'
  }

  shinyApp(
    ui=fluidPage(
      titlePanel(""),
      fluidRow(
        column(3,
               wellPanel(
                 sliderInput("tension", "Tension", 0.3,min=0,max=1,step = 0.01),
                 sliderInput("fontsize","Font size",12,min=6,max=24),
                 sliderInput("width","Width and height",600,min=200,max=1200),
                 sliderInput("padding","Padding",100,min=0,max=300),
                 uiOutput("cutoffui")

               ),
               wellPanel(
                 downloadButton("export",label="Download")
               ),
               wellPanel(
                 icon("warning"),
                 tags$small("The edgebundleR package is under active development."),
                 tags$small("Report issues here: "),
                 HTML(paste("<a href=http://github.com/garthtarr/edgebundleR/issues>")),
                 icon("github"),
                 HTML(paste("</a>"))
               )
        ),
        column(9,
               #verbatimTextOutput("type"),
               uiOutput("circplot")
        )
      )
    ),
    shinyServer(function(input, output) {

      output$circplot <- renderUI({
        edgebundleOutput("eb", width = input$width, height=input$width)
      })

      output$type=reactive({type})
      outputOptions(output, 'type', suspendWhenHidden=FALSE)

      output$cutoffui <- renderUI({
        conditionalPanel(
          condition = "output.type == 'symmat'",
          sliderInput("cutoff","Cutoff",0.2,min=0,max=1)
        )
      })

      output$export = downloadHandler(
        filename = "edgebundle.html",
        content = function(file){
          saveEdgebundle(edgebundle(x,tension=input$tension,
                                    cutoff=input$cutoff,
                                    fontsize = input$fontsize,
                                    width=input$width),
                         file=file)
        }
      )

      output$eb <- renderEdgebundle({
        edgebundle(x,tension=input$tension,cutoff=input$cutoff,
                   fontsize=input$fontsize,padding=input$padding)
      })

    })
  )
}
