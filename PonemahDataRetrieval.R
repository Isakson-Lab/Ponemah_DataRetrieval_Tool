
ui <- fluidPage(
  titlePanel("Telemeter Dana Analysis Shiny App"),
  
  fileInput("Datainput", "Please select Telemeter Data", multiple = FALSE, accept = ".csv",
            width = NULL, buttonLabel = "Browse...",
            placeholder = "No file selected"),
  actionButton("Analyze", "Analyze!"),
  
  tableOutput("results"),
  
  actionButton("SaveFile", "Save Your File?")
)
server <- function(input, output) {
  options(shiny.maxRequestSize=1000*1024^2)

  library(tidyr)
  library(dplyr)
  library(readxl)
  library(shiny)


observeEvent(input$Analyze, {xl_data <- input$Datainput[[4]] 
                          
                          tab_names <- excel_sheets(path = xl_data)
                          tab_name  <- grep("^Parameters", tab_names,value=TRUE)
                          tab_no <- as.data.frame(tab_name)
                          tab_no$tab_name <- as.character(tab_no$tab_name)
                          tab_nop = substr(tab_no$tab_name,12,nchar(tab_no$tab_name))
                          importlist <- lapply(tab_name, function(x) read_excel(path = xl_data, sheet = x))
                          names(importlist) <- tab_nop
                          QTPFrame <- bind_rows(importlist, .id = "id")
                          QTFrame <- QTPFrame[c(1:2,9:12)]
                          SQTFrame <- separate(QTFrame, Date, into= c("Date", "Time"), sep=" ")
                          SQTFrame$Time <- gsub("[:]", "" , SQTFrame$Time, perl=TRUE)
                          SQTFrame$Time = substr(SQTFrame$Time,1,nchar(SQTFrame$Time)-2)
                          SQTFrame$Time <- as.numeric(as.character(SQTFrame$Time))
                          #########Get Avg For each 6am-6pm Block, by date#############################################################
                          inds = which(SQTFrame$Time == 1800 | SQTFrame$Time == 600)
                          
                          eind = length(importlist[[1]][[7]])*(1:length(importlist))
                          
                          lisend = (1:length(importlist))*length(inds)/length(importlist)
                          
                          #########Get inds-1, then inds+720 after last for end of collection##########################################
                          indss = inds-1
                          indss = indss[-1]
                          indss = append(indss, inds[length(inds)]+719, after = length(indss))
                          
                          #######Last index for each mouse must be replaced in order to avoid analyzing beginning of next mouse########
                          indsss <- replace(indss, lisend, eind)
                          
                          #############Number of rows for each analysis################################################################
                          ind = indsss - inds
                          
                          #########Get row numbers as lists for analysis##########################################################
                          rows <- NULL
                          loopy <- NULL               
                          rows <- as.list(rows)
                          
                          for(i in 1:length(inds)) {
                            
                            loopy <- inds[i]:indsss[i]
                            rows[[i]] <- loopy
                            
                          }
                          
                          SQTFrame <- as.data.frame(SQTFrame)
                          SQTFrame[[3]] <- as.numeric(SQTFrame[[3]])
                          
                          #########################For loop to analyze based on row numbers#############################################
                          
                          Dayavg <- NULL
                          avg <- NULL
                          Dayavg <- as.list(Dayavg)
                          
                          for (i in 1:length(rows)) {
                            
                            
                            
                            avg <- colMeans(SQTFrame[rows[[i]], 4:7], na.rm=TRUE)
                            Dayavg[[i]] <- avg
                            
                          }
                          
                          #####################TIDY THAT SHIZZ UP!#######################################################################
                          Tidyavg <- Dayavg
                          
                          indsn  <- QTFrame[inds, 2]
                          name <- QTFrame[inds, 1]
                          
                          indsnn  <- as.character(indsn[[1]])
                          namen   <- as.character(name[[1]])
                          
                          names(Tidyavg) <- indsnn
                          
                          #################Add Mouse name to each list object############################################################
                          nam <- NULL
                          Tidynam <- NULL
                          Tidynam <- as.list(Tidynam)
                          
                          for (i in 1:length(Tidyavg)) {
                            
                            
                            
                            nam <- c(Tidyavg[[i]], namen[i])
                            Tidynam[[i]] <- nam
                            nam <- NULL
                          }
                          
                          ################Add Analysis Length to each entry###################################################################
                          Analength <- ind
                          
                          Tidyavgg = NULL
                          Tidyavgg <- as.list(Tidyavgg)
                          AL <- NULL
                          
                          for (i in 1:length(Tidynam)) {
                            
                            
                            
                            AL <- c(Tidynam[[i]], Analength[i])
                            Tidyavgg[[i]] <- AL
                            AL <- NULL
                          }
                          
                          
                          names(Tidyavgg) <- indsnn
                          
                          colnames <- c("Sys","Dias","Mean", "HR", "Mouse ID", "Analysis Length")
                          
                          
                          
                          Tidyav  <-  lapply(Tidyavgg, setNames, colnames)
                          
                          
                          Tidyaf <- as.data.frame(Tidyav)
                          Tidyaff = t(Tidyaf)
                          
                          STidyaf = substr(row.names(Tidyaff),2,nchar(row.names(Tidyaff)))
                          
                          rownames(Tidyaff) <- STidyaf
                          
                          
                          Tidynf <- as.data.frame(Tidyaff)
                          Tidynff <- tibble::rownames_to_column(Tidynf, "Time")
                          
                          RefTidy <- separate(Tidynff, Time, into= c("Date", "Time"), sep=11)
                          
                          RefTidy[1] <- substring(RefTidy[[1]], 1, nchar(RefTidy[[1]])-1)
                          RefTidy[2] <- substring(RefTidy[[2]], 1, 2)
                          
                          RefTidy[2] <- gsub("06", "Day" , RefTidy[[2]], perl=TRUE)
                          RefTidy[2] <- gsub("18", "Night" , RefTidy[[2]], perl=TRUE)
                          
                          RefTidy <- RefTidy[, c(7, 1, 2, 3, 4, 5, 6, 8)]
                          ReffTidy <- as.data.frame(lapply(RefTidy, as.character), stringsAsFactors = FALSE)
                          
                          ReffTidyy <- head(do.call(rbind, by(ReffTidy, RefTidy$`Mouse ID`, rbind, "")), -1 )
                          
                          rownames(ReffTidyy) <- 1:nrow(ReffTidyy)
                          
                          
                          
                          
                          
                          output$results <- renderTable({ReffTidyy})
                          
                          Savname = substr(input$Datainput[1],1,nchar(input$Datainput[1])-5)
                          
                          Savname = paste(Savname, "_averages.csv", sep="")

                          observeEvent(input$SaveFile, {write.csv(ReffTidyy, file = Savname)}) 
                          
                          })
  
  
  

}
shinyApp(ui = ui, server = server)

