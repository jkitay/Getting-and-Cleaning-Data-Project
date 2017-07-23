library(dplyr)

#Create directory and download data for project
if(!file.exists("./GCProject")){dir.create("./GCProject")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile = "./GCProject/ProjectData.zip")

if (!file.exists("UCI HAR Dataset")) { 
        unzip('ProjectData.zip') 
}

library(reshape2)


# Load activity labels/features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
meanSTD_Features <- grep(".*mean.*|.*std.*", features[,2])
meanSTD_tidy <- features[meanSTD_Features,2]
meanSTD_tidy = gsub('-mean', 'Mean', meanSTD_tidy)
meanSTD_tidy = gsub('-std', 'Std', meanSTD_tidy)
meanSTD_tidy <- gsub('[-()]', '', meanSTD_tidy)


# Load the datasets
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")[meanSTD_Features]
trainLabels <- read.table("UCI HAR Dataset/train/Y_train.txt")
TrainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(TrainSubjects, trainLabels, x_train)

x_test <- read.table("UCI HAR Dataset/test/X_test.txt")[meanSTD_Features]
testLabels <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testLabels, x_test)

# merge datasets and add labels
dataSet <- rbind(train, test)
colnames(dataSet) <- c("subject", "activity", meanSTD_tidy)
View(dataSet)
# turn activities & subjects into factors
dataSet$activity <- factor(dataSet$activity, levels = activityLabels[,1], labels = activityLabels[,2])
dataSet$subject <- as.factor(dataSet$subject)

dataSet_melt <- melt(dataSet, id = c("subject", "activity"))
dataSet_solution<- dcast(dataSet_melt, subject + activity ~ variable, mean)

write.table(dataSet_solution, "tidy.txt", row.names = FALSE, quote = FALSE)
