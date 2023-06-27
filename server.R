

server <- function(input, output, session) {
  
  library("tidyverse")
  library("shiny")
  library("dplyr")
  library("factoextra")
  library("cluster")
  library("NbClust")
  library("ClusterR")
  library("mclust")
  library("fpc")
  library("modeest")
  library("fastDummies")
  library("ramify")
  library("scales")
  library("shinyjs")
  library("vcd")
  source('functions.R')

  
  # Hide or show options depending on the algorithm choice
  
  observe({
    
    observe({
      shinyjs::toggle(id = "knumber", condition = input$method!='GMM')
      shinyjs::toggle(id = "k.suggested", condition = input$method!='GMM')
    })
    
  })
  
  #Load data
  
  datafile <- reactive({
    
    withProgress(message = 'Loading data',{
      
      file <- input$file
      if (is.null(file)) {return(data.frame(defaultDataSources[["Example 1: Default data 1"]]))}
      
      else{
        ext <- tools::file_ext(file$datapath)
        req(file)
        validate(need(ext == "csv", "Please upload a csv file"))
        read.csv(file$datapath)
        
      }
    })
    
  })
  
  #Clean data
  
  data.process <- reactive({
    
    withProgress(message = 'Cleaning data',{
      
      incProgress(1/3)
      data.clean <- prepare.data(datafile())
      incProgress(1/3)
      data.reduced <- pca(data.clean)
      return(data.reduced)
      
    })
  })
  
  # Compute clusters
  
  cluster.solution <- reactive({
    
    data.fixed.pca <- data.process()
    
    if (input$method=='kmeans') {
      
      withProgress(message = 'Creating clusters',{
        
        incProgress(1/4)
        
        clustering_results <- list()
        
        for (i in 1:input$iterations) {
          
          clusters <- kmeans(data.fixed.pca, centers = input$knumber)
          clustering_results[[i]] <- clusters$cluster
          
        }
        
        incProgress(1/4)
        
        All_Clusters<-data.frame(clustering_results)
        
        for (i in seq_along(All_Clusters)) {
          colnames(All_Clusters)[i] <- paste0("sol", i)
        }
        
        incProgress(1/4)
        
        CC.clusters.sol <- as.numeric(apply(All_Clusters, 1, function(row) {
          table_row <- table(row)
          names(table_row)[which.max(table_row)]
        }))
        
      })
      
    }
    
    if (input$method=='Hierarchical') {
      
      withProgress(message = 'Creating clusters',{
        
        incProgress(1/4)
        
        clustering_results <- list()
        
        for (i in 1:input$iterations) {
          
          hc <- hclust(dist(data.fixed.pca))
          clusters <- cutree(hc, k = input$knumber)
          clustering_results[[i]] <- clusters
          
        }
        
        incProgress(1/4)
        
        All_Clusters<-data.frame(clustering_results)
        
        for (i in seq_along(All_Clusters)) {
          colnames(All_Clusters)[i] <- paste0("sol", i)
        }
        
        incProgress(1/4)
        
        CC.clusters.sol <- as.numeric(apply(All_Clusters, 1, function(row) {
          table_row <- table(row)
          names(table_row)[which.max(table_row)]
        }))
        
      })
    }
    
    if (input$method=='GMM') {
      
      withProgress(message = 'Creating clusters',{
        
        incProgress(1/3)
        CC.clusters <- Mclust(data.fixed.pca)
        incProgress(1/3)
        CC.clusters.sol <- CC.clusters$classification
        
      })
      
    }
    
    return(CC.clusters.sol)
    
  })
  
  # Optimal number of clusters
  
  output$k.suggested <- renderText({
    
    withProgress(message = 'Computing optimal number of clusters',{
      
      if (input$method=='kmeans') {
        
        incProgress(1/3)
        optimal.k <- c.number(data.process(),'kmeans')
        incProgress(1/3)
        msg<-paste0("Based on your data, the optimal number clusters is up to ",optimal.k[3])
        
      }
      
      if (input$method=='Hierarchical') {
        
        incProgress(1/3)
        optimal.k <- c.number(data.process(),'complete')
        incProgress(1/3)
        msg<-paste0("Based on your data, the optimal number clusters is up to ",optimal.k[3])
        
      }
      
      if (input$method=='GMM') {
        
        msg<-paste0("Based on your data, the optimal number clusters is up to ",length(unique(cluster.solution())))
        
      }
    })
    
    return(msg)
    
  })
  
  # Download all data
  
  data.export <- reactive({
    
    Cluster <- cluster.solution()
    export <- data.frame(cbind(datafile(),Cluster))
    
    clus_name <- paste0('Cluster_',input$method,'_',input$knumber)
    
    if (input$method!="GMM") {
      
      col_names <- c(colnames(export)[-ncol(export)],paste0('Cluster_',input$method,'_',input$knumber))
      colnames(export) <- col_names
      
    }
    
    if (input$method=="GMM") {
      
      col_names <- c(colnames(export)[-ncol(export)],paste0('Cluster_',input$method))
      colnames(export) <- col_names
      
    }
    
    return(export)
    
  })
  
  output$downloadData <- downloadHandler(
    
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(data.export(), file,row.names = FALSE)
    }
  )
  
  # Download only clusters 
  
  data.export2 <- reactive({
    
    Cluster <- cluster.solution()
    participant_id <- datafile()[,1]
    export <- data.frame(cbind(participant_id,Cluster))
    
    clus_name <- paste0('Cluster_',input$method,'_',input$knumber)
    
    if (input$method!="GMM") {
      
      col_names <- c(colnames(export)[-ncol(export)],paste0('Cluster_',input$method,'_',input$knumber))
      colnames(export) <- col_names
      
    }
    
    if (input$method=="GMM") {
      
      col_names <- c(colnames(export)[-ncol(export)],paste0('Cluster_',input$method))
      colnames(export) <- col_names
      
    }
    
    return(export)
    
  })
  
  output$downloadData2 <- downloadHandler(
    
    filename = function() {
      paste("data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(data.export2(), file,row.names = FALSE)
    }
  )
  
  # Cluster distribution
  
  output$donut<-renderPlot({
    
    data<-data.export()
    
    data$Cluster<-as.factor(data$Cluster)
    
    donut<-data %>%group_by(Cluster)%>%count(Cluster)
    donut$freq<-donut$n/sum(donut$n)
    donut$ymax <- cumsum(donut$freq)
    donut$ymin <- c(0, head(donut$ymax, n=-1))
    donut$labelPosition <- (donut$ymax + donut$ymin) / 2
    donut$label <- paste0(donut$Cluster, "\n value: ", round(donut$freq,2))
    
    paste0(donut$Cluster,' - ',round(donut$freq,4)*100,'%')
    
    ggplot(donut, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=Cluster)) +
      geom_rect() +
      coord_polar(theta="y") +
      xlim(c(1.5, 4)) +
      theme_void()+
      scale_fill_discrete(labels=paste0('Cluster ',donut$Cluster,' - Share: ',round(donut$freq,4)*100,'%'))+
      theme(legend.title = element_blank())
    
  })
  
  # Categorical variables
  
  output$CVariables<-renderUI({
    
    data<-data.export()
    
    character<-data[, sapply(data, class) == 'character']
    labels<-names(character)
    
    selectInput("x_axis","Categorical variable to plot",choices = 
                  labels,selected=labels[1],multiple = FALSE)
    
  })
  
  # Categorical chart
  
  output$CChart<-renderPlot({
    
    data<-data.export()
    
    col <- which( colnames(data)==input$x_axis)
    mosaic_data <- data.frame(cbind(data[,col],data$Cluster))
    
    mosaic(~ X2 + X1, data = mosaic_data,
           shade=TRUE,rot_labels=c(0,90,90),split_vertical=TRUE)
    
  })
}