# Ponemah_DataRetrieval_Tool
A small shiny app which does simple analysis on the output of Ponemah telemeter software. Day/night averages of any subject saved as a sheet in the excel file will be calculated for systolic/diastolic/mean arterial pressures and can then be saved as a new .csv file.


Day/night averages are calculated based on 6am-6pm timestamps for each date, by identifying the timestamps for each and averaging the next 720 minutes. This means that some entries may not have the full 12 hours, which will be indicated in the analysis length column of the output. 
