# Codebook

humActRecogTidy.csv
-------------------
This tidy dataset contains 10,299 observations collected from 30 volunteers (ages 19-48 years old) who wore a smartphone (Samsung Galaxy S II) on their waist while performing six different activities (walking, walking upstatirs, walking downstairs, sitting, standing, and laying). The dataset contains 68 variables in total. The first two variables are given by:

**subjectid:** integer ID variable for the 30 volunteers (1-30)

**activity:** character variable giving the activity (Walking, Walking Upstatirs, Walking Downstairs, Sitting, Standing, or Laying) performed by the volunteer

The remaining 66 variables were extracted from the raw data per course project instructions to "Extract only the measurements on the mean and standard deviation for each measurement." The raw data contain 561 feature variables that were derived from the acclerometer and gyroscope signals of the smart phone during the activity. To isolate the feature variables of interest, a file from the raw data containing the 561 feature names, features.txt, was read and 2 queries were given: 

  (1) grep("[Mm]ean|[Ss]td",features$V1) # match lines with "(Mm)ean" or "(Ss)td"
  
  and 

  (2) grep("Freq|angle",features$V1) # match lines with "Freq" or "angle"

Feature names that matched (1) and NOT (2) were returned so that only feature names containing "mean()" or "std()" (and not "meanFreq()" or angle variables like "angle(X,gravityMean)") were extracted. Of the original 561 feature variables, 66 were extracted using this approach. The 66 extracted feature variables were descriptively named according to the following schema:

[prefix]["mean" or "std"][axis, if applicable]

For example, the feature name "1 tBodyAcc-mean()-X" found in features.txt is named tbodyaccmeanx in this tidy dataset. Similarly, the feature name "45 tGravityAcc-std()-Y" found in features.txt is named tgravityaccstdy.

humActRecogTidyGrouped.csv
--------------------------
This tidy dataset is obtained by taking the previously described tidy datset (humActRecogTidy.csv) and calculating the average of each of the 66 feature variables for each activity and each volunteer. Accordingly, there are 30*6=180 observations and 68 variables in this dataset. Note that the 66 variables containing said averages have been named by appending "mean" to the original feature variable name found in humActRecogTidy.csv. For example, the mean of tbodyaccmeanx is given by tbodyaccmeanxmean in this dataset. Similarly, the mean of tgravityaccstdy is given by tgravityaccstdymean.
