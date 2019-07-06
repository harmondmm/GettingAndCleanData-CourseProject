# This script performs the following functions:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of 
#    each variable for each activity and each subject.

# The data linked to from the course website represent data collected from the accelerometers from the 
# Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

  #http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones



##############################################################################################
#Install packages and libraries
##############################################################################################
install.packages("data.table")
library(data.table)
install.packages("dplyr")
library("dplyr")


##############################################################################################
#Get course project data
##############################################################################################
projectdata <- "getdata_projectfiles_UCI_HAR_Dataset.zip"

# Checking if archieve exists.
if (!file.exists(projectdata)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, projectdata, method="curl")
}  

# Checking if folder exists
if (!file.exists("UCI HAR Dataset")) { 
  unzip(projectdata) 
}


##############################################################################################
#Set table for feature column names and indexes
##############################################################################################
featureDT <- data.table::fread("./UCI HAR Dataset/features.txt" 
                               , select = c(1, 2)
                               , col.names=c("FeatureID", "FeatureName"))

#Clean up column names.
featureNameClean = tolower(featureDT$FeatureName)
featureNameClean = sub(",","-",featureNameClean);
featureNameClean = gsub("[()]","",featureNameClean)


##############################################################################################
#Set table for activity labels
##############################################################################################
activityLabelsDT <- data.table::fread("./UCI HAR Dataset/activity_labels.txt" 
                              , select = c(1, 2)
                              , col.names=c("activityid", "activityname"))


##############################################################################################
#TRAINING DATA SET PROCESSING
##############################################################################################
#Load subject_train.txt for subject train data
subjectTrainDT <- data.table::fread("./UCI HAR Dataset/train/subject_train.txt" 
                                   , select = c(1)
                                   , col.names=c("subjectid"))

#Load y_train.txt for train labeling data
labelTrainDT <- data.table::fread("./UCI HAR Dataset/train/y_train.txt" 
                                    , select = c(1)
                                    , col.names=c("labelid"))

#Load training set data. Original file train/X_train.txt. #Num of Cols 561. Records 7352
xTrainDataSetDT <- data.table::fread("./UCI HAR Dataset/train/X_train.txt"
                                     , select = featureDT$FeatureID
                                     , col.names = featureNameClean)
#Check for duplicate column names
duplicated(colnames(xTrainDataSetDT))

#Make sure column names are unique
colnames(xTrainDataSetDT) = make.names(featureNameClean, unique = TRUE)

#Create new column labelid on the left side of the data set
xTrainDataSetDT <- rename(cbind(labelTrainDT$labelid, xTrainDataSetDT),labelid=V1)
#Create new column subjectid on the left side of the data set
xTrainDataSetDT <- rename(cbind(subjectTrainDT$subjectid, xTrainDataSetDT),subjectid=V1)


##############################################################################################
#TEST DATA SET PROCESSING
##############################################################################################
#Load subject_test.txt for test data
subjectTestDT <- data.table::fread("./UCI HAR Dataset/test/subject_test.txt" 
                                      , select = c(1)
                                      , col.names=c("subjectid"))

#Load y_test.txt for test labeling data
labelTestDT <- data.table::fread("./UCI HAR Dataset/test/y_test.txt" 
                                  , select = c(1)
                                  , col.names=c("labelid"))

#Load test set data. Original file test/X_test.txt. #Num of Cols 561. Records 2947
xTestDataSetDT <- data.table::fread("./UCI HAR Dataset/test/X_test.txt"
                                    , select = featureDT$FeatureID
                                    , col.names = featureNameClean)

#Check for duplicate column names
duplicated(colnames(xTestDataSetDT))

#Make sure column names are unique
colnames(xTestDataSetDT) = make.names(featureNameClean, unique = TRUE)

#Create new column labelid on the left side of the data set
xTestDataSetDT <- rename(cbind(labelTestDT$labelid, xTestDataSetDT),labelid=V1)
#Create new column subjectid on the left side of the data set
xTestDataSetDT <- rename(cbind(subjectTestDT$subjectid, xTestDataSetDT),subjectid=V1)



##############################################################################################
#Merges the training and the test sets to create one data set.
##############################################################################################
MergedTestTrainDSDT <- data.table(rbind(xTrainDataSetDT,xTestDataSetDT))
# number of records total should be 10299 at this point
nrow(MergedTestTrainDSDT)


##############################################################################################
# Step 2
# Extracts only the measurements on the mean and standard deviation for each measurement.
##############################################################################################

#Create vectors that contains index of column with "mean" and "std" in the name
meanDT <- MergedTestTrainDSDT[,grep("mean",colnames(MergedTestTrainDSDT))]
stdDT <- MergedTestTrainDSDT[,grep("std",colnames(MergedTestTrainDSDT))]

#Bind the data and add data label and subject identifiers
FinalMergedTestTrainDSDT <- cbind(select(MergedTestTrainDSDT, meanDT),select(MergedTestTrainDSDT, stdDT))
FinalMergedTestTrainDSDT <- rename(cbind(MergedTestTrainDSDT$labelid, FinalMergedTestTrainDSDT),labelid=V1)
FinalMergedTestTrainDSDT <- rename(cbind(MergedTestTrainDSDT$subjectid, FinalMergedTestTrainDSDT),subjectid=V1)


##############################################################################################
# Step 3
# Uses descriptive activity names to name the activities in the data set
##############################################################################################

ActivityFinalMergedTestTrainDSDT <- merge(activityLabelsDT, FinalMergedTestTrainDSDT, 
                                          by.x = "activityid",
                                          by.y = "labelid",
                                          all = FALSE)


##############################################################################################
# Step 4
# Appropriately labels the data set with descriptive variable names.
##############################################################################################

colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("acc", "Accelerometer", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("gyro", "Gyroscope", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("mag", "Magnitude", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("^t", "Time", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("^f", "Frequency", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("meanfreq", "meanFrequency", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("angle", "Angle", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("gravity", "Gravity", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("jerk", "Jerk", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("tBody", "TimeBody", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("std", "STD", colnames(ActivityFinalMergedTestTrainDSDT), ignore.case = TRUE)
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("bodybody", "Body", colnames(ActivityFinalMergedTestTrainDSDT))
colnames(ActivityFinalMergedTestTrainDSDT)<-gsub("body", "Body", colnames(ActivityFinalMergedTestTrainDSDT))

##############################################################################################
# Step 5
# From the data set in step 4, creates a second, independent tidy data set with the average of 
# each variable for each activity and each subject.
##############################################################################################

FinalTidyData <- ActivityFinalMergedTestTrainDSDT %>%
      group_by(activityid,activityname,subjectid) %>%
      summarise_all(funs(mean))

str(FinalTidyData)

write.table(FinalTidyData, "FinalTidyData.txt", row.name=FALSE)

