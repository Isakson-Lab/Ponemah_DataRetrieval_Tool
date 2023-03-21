# Ponemah_DataRetrieval_Tool
[![DOI](https://zenodo.org/badge/273366158.svg)](https://zenodo.org/badge/latestdoi/273366158)        
A small shiny app which does simple analysis on the output of Ponemah telemeter software. Day/night averages of any subject saved as a sheet in the excel file will be calculated for systolic/diastolic/mean arterial pressures and can then be saved as a new .csv file.


Day/night averages are calculated based on 6am-6pm timestamps for each date, by identifying the timestamps for each and averaging the next 720 minutes. This means that some entries may not have the full 12 hours, which will be indicated in the analysis length column of the output. 


The save file should be the file name with _averages, in the directory that the R file is in.


In order to use the app once opened, click the "Browse..." button and select the excel file, then click 'open'. Once the file has finished loading into the app, click "Analyze" the results of the analysis will then be displayed in the window to show a preview of the output and as a confirmation that the program has finished analysis. Next, click the "Save your file?" button. The saved analysis file should now be in the same folder as the '.R' file with an appended "_averages" at the end of the file name. The provided excel file named "PonemahDataRetrieval_SampleData" can be used as a test to make sure the app is working.
