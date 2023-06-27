# Clustering App prototype in R + Shiny

[Link to the shiny hosted app]( https://danielhernandez.shinyapps.io/ClusterV9/)

## Table of Contents

1. [Introduction](#introduction)
2. [Features](#features)
3. [Dependencies](#dependencies)
4. [Usage](#usage)
5. [Steps for users](#steps)


## Introduction

This code is a Shiny app that reads a CSV file, cleans and processes the data, reduces dimensionality using Principal Component Analysis (PCA), and clusters the data. The app then visualizes the results in a monadic plot. It is meant to be used for exploratory data analysis and is flexible to accommodate different types of data from Conjointly.

## Features

- Support for various clustering algorithms: K-Means, Hierarchical Clustering, and Gaussian Mixture Modelling (GMM).
- Data visualization for easy exploration and interpretation of results.
- User-friendly interface for selecting parameters and customizing algorithms.
- Extensive documentation for further customization.

## Dependencies

- R (>= 4.2.2)
- shiny (>= 1.7.4)
- dplyr (>= 1.0.10)
- factoextra (>= 1.0.7)
- cluster (>= 2.1.4)
- NbClust (>= 3.0.1)
- ClusterR (>= 1.2.9)
- mclust (>= 6.0.0)
- fpc (>= 2.2.9)
- diceR (>= 1.2.2)
- modeest (>= 2.4.0)
- fastDummies (>= 1.6.3)
- ramify (>= 0.3.3)
- tidyr (>= 1.2.1)
- scales (>= 1.2.1)
- shinyjs (>= 2.1.0)
- vcd (>= 1.4.10)
- BiocManager (>= 1.30.19)

Note: Please run this code before upload the app in shiny Apps

- library(BiocManager)
- options(repos = BiocManager::repositories())
- getOption("repos")
- packageVersion("Biobase")
- packageVersion("BiocGenerics")
- BiocManager::install("Biobase", version = "3.17")
- BiocManager::install("BiocGenerics", version = "3.17")


## Usage

### Reading Data
The app reads a CSV file using the fileInput widget. Only CSV files are allowed. By default, the app provides an example dataset that uses random data. If users want to upload a new dataset, they can click the browse button and select a CSV file.

### Prepare, Code, and Clean the Data

The prepare.data function takes the input data and performs various tasks to clean and format it for clustering analysis. It separates the data into numeric and character types, scales it, removes columns containing only zeros, and codes the character data into dummy variables using the fastDummies package. For multiple-choice data, it creates a matrix with rows representing each observation and columns representing each option. It codes the options into dummy variables, where a one indicates that the option was selected for that observation, and a 0 indicates that it was not selected. Finally, it combines the two data types and returns the cleaned and formatted data. (If you need an extensive description of the data processing, please visit [Cluster documentation](https://conjoint-ly.atlassian.net/wiki/spaces/DOCUMENTAT/pages/968851475/Cluster+tool+documentation))

### Reduce Dimensionality (PCA)
The PCA function takes the cleaned and formatted data as input and performs PCA. The function returns the principal components that explain at least one unit of variance.

### Determine the Optimal Number of Clusters
The c.number function determines the optimal number of clusters using the NbClust function, which applies several different clustering methods and returns the optimal number of clusters based on various cluster validity indices. For GMM, the optimal number of clusters is automatically computed.

### Shiny App
The shiny app creates an interface for the user to upload a CSV file, select a clustering method, and view the results. When the user uploads a file, the fileInput function stores the data in a reactive variable that other app parts can access. The observed event function detects when the file has been uploaded and updates the interface accordingly.
The user can then select a clustering method from a drop-down menu. When a method is selected, the app uses the renderPlot function to display a plot of the optimal number of clusters based on the chosen method. The plot function is used to create the plot, which shows the number of clusters on the x-axis and various cluster validity indices on the y-axis.
When the user clicks the "Cluster" button, the app uses the selected method to perform clustering on the data. The results are displayed in a table showing each observation's cluster assignment.
Overall, this code provides a simple and easy-to-use interface for performing clustering analysis on user-provided data. The use of PCA for dimensionality reduction and the ability to select from several different clustering methods make this code a helpful tool for exploring and analyzing data.

## Steps for users

The following steps will guide you on how to use the cluster tool:

### Step 1: Prepare Your Data Set
To use the cluster tool, you must prepare a data set in .csv format. Here's how to prepare your data:
1. Start the first column with "participant_id".
2. Include the data you want to include in the clustering exercise.
  - Any questions in your experiment can be added (except for Gabor-Granger results and Open-End answers).
  - You can also include individual preferences if you want to include preferences in the clustering exercise.
  - If you have multiple-choice questions, please include the column with the text responses instead of the binary columns.
3. Save your data set in .csv format.

### Step 2: Upload Your Data Set
1. Open the Shiny app and upload your .csv file using the browse button.
2. Once the user has uploaded the file, you can start the cluster analysis.

### Step 3: Select the Parameters for the Analysis

1. If you’re using Kmeans and Hierarchical clustering, you will need to include the desired number of clusters.
2. You can also specify the number of iterations (the number of times a cluster solution will be computed).

### Step 4: Perform the Cluster Analysis

1. Once you have uploaded the data set and specified the parameters, you can perform the cluster analysis using the selected algorithm.
2. The tool will provide you with a recommended number of clusters, but you can also specify the number of clusters you want.

### Step 5: Interpret the Results

1. Once the cluster analysis is complete, you will see a brief distribution of the cluster solution.
2. In the insights tab, a plot will be displayed. The plot can be interpreted as follows:

there are more respondents from group 2 who prefer oats compared to a scenario where the variable "group" and "main ingredient" are independent
![image](https://user-images.githubusercontent.com/82115133/227393008-64f3a1e7-9afb-49b9-8375-db5f2d4757ae.png)

3. You can download the entire data set with the results or only the IDs and cluster solutions.

### Opportunities for Improvement
To further improve the clustering tool, we can do the following:

- Include a brief description of the cluster algorithm used and how it works.
- Allow the user to select different clustering algorithms per calculation and compare the results.
- Provide additional statistics and metrics for evaluating the quality of the clustering results. For example, clusterboot (Clusterwise cluster stability assessment by resampling)
