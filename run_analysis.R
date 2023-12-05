
######### run_analysis.R

library(tidyverse) # load tidyverse library

# Set working directory (Change as necessary)
# Will also need to change paths to read in data based on your local machine configuration
setwd("./Data Science Specialization/Getting and Cleaning Data/Course Project")

# Define "notin" function
"%notin%"<-Negate("%in%") # Define "notin" function


############################## Features ##############################

######### Get features of interest (measurements on the mean and standard deviation)

# Read in features.txt
# Contain list of 561 features
features <- read.table("./UCI HAR Dataset/features.txt",sep='\t')

grep1 <- grep("[Mm]ean|[Ss]td",features$V1) # match lines with "(Mm)ean" or "(Ss)td"

#temp1 <- as.data.frame(features[grep1,])

grep2 <- grep("Freq|angle",features$V1) # match lines with "Freq" or "angle"

#temp2 <- as.data.frame(features[grep2,])

# Final indices for features of interest
# Want variables with mean() or std() only, so need to remove lines with "meanFreq()" or "angle(X,gravityMean)"
finalgrep <- grep1[grep1 %notin% grep2] 

# Use finalgrep indices to get variables of interest
# Will use meanstdvars to automate variable naming of features
featureNames <- as.data.frame(features[finalgrep,]) 


######### Construct descriptive names for features of interest

featureNames <- featureNames %>% rename(feature="features[finalgrep, ]") %>%
    mutate(
        
        # Remove leading numbers from name given in features.txt 
        feature = sub("[0-9]* ","",feature), # replace any number of digits followed by a space with ""
        
        # Indicators for whether variable is mean or std
        meanVar = ifelse(grepl("mean",feature)==TRUE,1,0),
        stdVar  = ifelse(grepl("std",feature)==TRUE,1,0),
        
        # From stringr package, extract everything to the left of "-"
        prefix = word(feature,1,sep="-"), 
        # prefix = sub("-.*","",feature)  # does same as above using regular expression
        
        # Indicators for whether variable is x,y, or z var
        # Note: Some variables will have xVar=yVar=zVar=0
        xVar = ifelse(grepl("X$",feature)==TRUE,1,0), # if last char is "X", xVar=1. xVar=0 otw
        yVar = ifelse(grepl("Y$",feature)==TRUE,1,0), 
        zVar = ifelse(grepl("Z$",feature)==TRUE,1,0),
        
        # Get final names
        finalName = case_when(
            meanVar == 1 & xVar == 1 ~ tolower(paste(prefix,"Mean","X",sep="")),
            meanVar == 1 & yVar == 1 ~ tolower(paste(prefix,"Mean","Y",sep="")),
            meanVar == 1 & zVar == 1 ~ tolower(paste(prefix,"Mean","Z",sep="")),
            meanVar == 1 & xVar == 0 & yVar == 0 & zVar == 0 ~ tolower(paste(prefix,"Mean",sep="")),
            
            stdVar == 1 & xVar == 1 ~ tolower(paste(prefix,"Std","X",sep="")),
            stdVar == 1 & yVar == 1 ~ tolower(paste(prefix,"Std","Y",sep="")),
            stdVar == 1 & zVar == 1 ~ tolower(paste(prefix,"Std","Z",sep="")),
            stdVar == 1 & xVar == 0 & yVar == 0 & zVar == 0 ~ tolower(paste(prefix,"Std",sep=""))
        )
    )


############################## TRAINING ##############################

######### Get Training Subject ID dataset

trainid <- read.table("./UCI HAR Dataset/train/subject_train.txt",sep='\t')

######### Get Training Feature Data

# Each row corresponds to a feature vector (char vector) of length 561 with time and frequency domain variables

traindata <- read.table("./UCI HAR Dataset/train/X_train.txt",sep='\t')

traindata <- traindata %>% rename(vector = V1) %>%
    mutate(
        vector = str_trim(vector,side='left'), # remove leading blank space
        vector = gsub("  "," ",vector) # replace double spaces with a single space
    )

# Split on " ". Returns list where each list element is a char vector with 561 entries
trainsplit <- strsplit(traindata$vector," ") 

rm(traindata) # don't need anymore

# Represent each feature as a distinct numeric column

# Create empty data frame
# Note: length(trainsplit) = number of observation in training dataset
# Note: length(trainsplit[[1]]) = number of features in char vector
trainfeatdata <- data.frame(matrix(ncol=length(trainsplit[[1]]),nrow=length(trainsplit)))

# Populate with split dataset
for(i in 1:nrow(trainfeatdata)) 
    {
    for(j in 1:ncol(trainfeatdata))
        {trainfeatdata[i,j] <- as.numeric(trainsplit[[i]][j])}
    }

trainfeatdata <- trainfeatdata[,finalgrep]     # filter on feature variables of interest
names(trainfeatdata) <- featureNames$finalName # give descriptive feature names


######### Get Training Label Dataset

# Note:
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING

trainlabel <- read.table("./UCI HAR Dataset/train/y_train.txt",sep='\t')


######### Construct Final Training dataset

train <- trainid %>% rename(subjectid=V1) %>% # use subjectid to id volunteers
    mutate(
        act=trainlabel$V1, # add label data
        activity = case_when( # make activity variable descriptive
            act == 1 ~ "Walking",
            act == 2 ~ "Walking Upstairs",
            act == 3 ~ "Walking Downstairs",
            act == 4 ~ "Sitting",
            act == 5 ~ "Standing",
            act == 6 ~ "Laying",
        )
    ) %>% select(-(act))

train <- cbind(train,trainfeatdata) # merge with feature data

# Remove stuff you don't need anymore
rm(trainid,trainlabel,trainsplit,trainfeatdata)


############################## TEST ##############################
# NOTE: code is identical to TRAINING code

######### Get Test Subject ID dataset

testid <- read.table("./UCI HAR Dataset/test/subject_test.txt",sep='\t')

######### Get Test Feature Data

# Each row corresponds to a feature vector (char vector) of length 561 with time and frequency domain variables

testdata <- read.table("./UCI HAR Dataset/test/X_test.txt",sep='\t')

testdata <- testdata %>% rename(vector = V1) %>%
    mutate(
        vector = str_trim(vector,side='left'), # remove leading blank space
        vector = gsub("  "," ",vector) # replace double spaces with a single space
    )

# Split on " ". Returns list where each list element is a char vector with 561 entries
testsplit <- strsplit(testdata$vector," ") 

rm(testdata) # don't need anymore

# Represent each feature as a distinct numeric column

# Create empty data frame
# Note: length(testsplit) = number of observation in testing dataset
# Note: length(testsplit[[1]]) = number of features in char vector
testfeatdata <- data.frame(matrix(ncol=length(testsplit[[1]]),nrow=length(testsplit)))

# Populate with split dataset
for(i in 1:nrow(testfeatdata)) 
    {
    for(j in 1:ncol(testfeatdata))
        {testfeatdata[i,j] <- as.numeric(testsplit[[i]][j])}
    }

testfeatdata <- testfeatdata[,finalgrep]     # filter on feature variables of interest
names(testfeatdata) <- featureNames$finalName # give descriptive feature names


######### Get Test Label Dataset

# Note:
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING

testlabel <- read.table("./UCI HAR Dataset/test/y_test.txt",sep='\t')


######### Construct Final Test dataset

test <- testid %>% rename(subjectid=V1) %>% # use subjectid to id volunteers
    mutate(
        act=testlabel$V1, # add label data
        activity = case_when( # make activity variable descriptive
            act == 1 ~ "Walking",
            act == 2 ~ "Walking Upstairs",
            act == 3 ~ "Walking Downstairs",
            act == 4 ~ "Sitting",
            act == 5 ~ "Standing",
            act == 6 ~ "Laying",
        )
    ) %>% select(-(act))

test <- cbind(test,testfeatdata) # merge with feature data

# Remove stuff you don't need anymore
rm(testid,testlabel,testsplit,testfeatdata)


############################## Combine/Export ##############################

# Stack Train and Test datasets to create one dataset

all <- rbind(train,test)          # stack
all <- all %>% arrange(subjectid) # order by subject id

# Export
if(!file.exists("./data")){dir.create("./data")}
write.csv(all,file = "./data/humActRecogTidy.csv",row.names=F)


# Create a second, independent tidy data set with the average of each variable for each activity and each subject

# Group by subjectid,activity then calculate means
grouped <- all %>% group_by(subjectid,activity) %>%
    summarize_all("mean")

# Rename calculated mean variables by appending "mean" to the end of feature names
names(grouped)[3:ncol(grouped)] <- paste(names(grouped)[3:ncol(grouped)],"mean",sep="")

# Export
if(!file.exists("./data")){dir.create("./data")}
write.csv(grouped,file = "./data/humActRecogTidyGrouped.csv",row.names=F)