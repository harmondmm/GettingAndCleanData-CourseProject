The run_analysis.R script performs the following data preparation and steps required by the project instructions.  The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.

Step 1. Download and install required packages and libraries
  -package/libraries data.table and dplyr
  
Step 2. Set working directory

Step 3. Download project course data
  - Download required zip file under directory UCIHARDataset
  
Step 4. Assign each dataset to data tables
  - featureDT <- data.table::fread("./UCIHARDataset/features.txt"
  The features selected for this database come from the accelerometer and gyroscope 3-axial
  raw signals tAcc-XYZ and tGyro-XYZ.
  
  - activityLabelsDT <- data.table::fread("./UCIHARDataset/activity_labels.txt"   
  List of activities performed.
  
  - subjectTrainDT <- data.table::fread("./UCIHARDataset/train/subject_train.txt"
  List of subjects 21/30 subjective to the experiment.
  
  - labelTrainDT <- data.table::fread("./UCIHARDataset/train/y_train.txt" 
  List of train data of activities labels
  
  - xTrainDataSetDT <- data.table::fread("./UCIHARDataset/train/X_train.txt"
  Contains 7352 recorded features as well as label and subject data.  
  Checks for duplicate column names.
  Resolves duplication of column names.
    
  - subjectTestDT <- data.table::fread("./UCIHARDataset/test/subject_test.txt" 
  List of subjects 9/30 subjective to the experiment.
  
  - labelTestDT <- data.table::fread("./UCIHARDataset/test/y_test.txt" 
  List of test data of activities labels
  
  - xTestDataSetDT <- data.table::fread("./UCIHARDataset/test/X_test.txt"
  Contains 2947 recorded features as well as label and subject data.
  Checks for duplicate column names.
  Resolves duplication of column names.
    
Step 5. Merges the training and the test sets to create one data set.
  - MergedTestTrainDSDT <- data.table(rbind(xTrainDataSetDT,xTestDataSetDT))
    Contains 10299 rows and 563 columns/variables
  
Step 6. Extracts only the measurements on the mean and standard deviation for each measurement.
  - Created vectors that contains index of columns with "mean" and "std" in the name
  - Used cbind to bind mean and std vectors to create data set FinalMergedTestTrainDSDT
  
Step 7. Uses descriptive activity names to name the activities in the data set
  - Use merge function to join activities names to data set matching on activity id and            label id
  
Step 8. Appropriately labels the data set with descriptive variable names.
  - Used gsub function to find and repleace column names with appropriate descriptive              variable names.  See lines 168 - 180.
  
Step 9. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
  - FinalTidyData (180 rows 89 variables) is created by sumarizing                                 ActivityFinalMergedTestTrainDSDT taking the means of each variable for each activity and       each subject, after groupped by subject and activity.
  - Export FinalTidyData.txt contains FinalTidyData data set.