
ui <- fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      shinyjs::useShinyjs(),
      
      fileInput(inputId = 'file',label = 'Choose a csv file',accept = '.csv'),
      selectInput(inputId = 'method',label = 'Select a cluster method',choices = c('GMM','kmeans','Hierarchical'),selected = 'GMM'),
      sliderInput(inputId = 'knumber',label = 'Select the number of clusters',min = 2,max = 20,value = 2,step = 1),
      textOutput('k.suggested'),
      numericInput(inputId = 'iterations',label = 'Specify the number of iterations' ,min = 3 ,max = 51 ,value = 5 ,step = 2),
      downloadButton("downloadData", "Download all data set"),
      downloadButton("downloadData2", "Download only clusters")
    ),
    
    mainPanel(
      tabsetPanel(
        # Summary Tab
        tabPanel(title = 'Summary',
                 h3('Cluster distribution'),
                 plotOutput('donut')
        ),
        
        # Insights
        tabPanel(title = 'insights',
                 h3('Profiling'),
                 uiOutput('CVariables'),
                 plotOutput('CChart')
                 )
      )
    )
  )
)