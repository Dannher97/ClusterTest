
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

#----------- Load scripts -----------

source('functions.R')
source('ui.R')
source('server.R')

shinyApp(ui, server)
