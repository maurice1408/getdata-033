# libraryies
library(dplyr)

GetFeatures <- function (base.dir, features.filename) {
  
  # This function reads the features file specified in feta and
  # returns a list of 2 vectors of 1) the field names that contain 
  # sum() or mean() and 2) vector contining the column positions
  # of the fields that match the regular expression.
  #
  
  # Look for feature names with std() or mean() at the end of the name
  # using the regular experession below. 
  # Note: the use of double \ to escape a regex character in a 
  kFeatureNamePattern <- "(std|mean)\\(\\)"
  
  # Width of each field in the fixed width record
  kFieldLength <- 16
  
  # Names ofr the columns in the features file
  kFeatureColnames <- c("Position", "FeatureName")
  
  # Build file path
  fp <- file.path(base.dir, features.filename)
  
  # Validate file exists
  if ( file.exists(fp) == FALSE ) {
    stop(paste("Features filename <",fp,"> not found."))
  }
  
  # Read the features dataset
  features <- read.table(fp, 
                         header = FALSE, 
                         stringsAsFactors = FALSE, 
                         col.names = kFeatureColnames)
  
  feature.names <- features$FeatureName

  r <- regexpr(kFeatureNamePattern, feature.names, ignore.case = TRUE)

  # Now turn r nto a vector of length 561, 16's for the columns we want or -16
  # for the columns we do not want i.e want to skip
  fmt <- ifelse(r > 0, kFieldLength, -1 * kFieldLength)

  # Get feature names
  fn <- filter(features, regexpr(kFeatureNamePattern, 
                                 feature.names, 
                                 ignore.case = TRUE) > 0)
  
  list("feature.names" = fn[,2], "data.fmt" = fmt)
}

MakeDescNames <- function(feature.names) {
  
  # Use gsub and sub to generate a descriptive set of feature column names
  
  # Replace "-" with "_"
  tn <- gsub("-", "_", feature.names)
  
  # Replace std() or mean() with StdDec and Mean
  tn <- sub("std\\(\\)", "StdDev", tn)
  tn <- sub("mean\\(\\)", "Mean", tn)
  
  # Replace starting t or f with Time and Freq
  tn <- sub("^t(.*)", "Time_\\1", tn)
  tn <- sub("^f(.*)", "Freq_\\1", tn)
  
  tn
  
}

GetData <- function(base.dir, activty.filename, subject.filename, observation.filename, observation.fwf) {
  
  # This function reads the single column activity and subject files and
  # the 561 field observation file and returns a data frame
  # of the 3
  
  # Number of expected columns in activity file and observation file
  kActColumns <- 1
  kSubColumns <- 1
  kObsColumns <- 561
  
  kActDesc <- c("Walking","Walking_Upstairs","Walking_Downstairs","Sitting","Standing","Laying")
  
  fpa <- file.path(base.dir, activty.filename)
  fps <- file.path(base.dir, subject.filename)
  fpo <- file.path(base.dir, observation.filename)
  
  # Validate that the files exist
  if ( file.exists(fpa) == FALSE ) {
    stop(paste("Activity file <", fpa, "> does not exist"))
  }
  
  if ( file.exists(fps) == FALSE ) {
    stop(paste("Subject file <", fps, "> does not exist"))
  }
  
  if ( file.exists(fpo) == FALSE ) {
    stop(paste("Observation file <", fpo, "> does not exist"))
  }
  
  activity.df <- read.table(fpa, header = FALSE)
  
  subject.df <- read.table(fps, header = FALSE)
  
  if (ncol(activity.df) != kActColumns) {
    stop(paste("Unexpected number of columns in the activity file", fpa, ncol(activity.df)))
  }
  
  if (ncol(subject.df) != kSubColumns) {
    stop(paste("Unexpected number of columns in the subject file", fps, ncol(subject.df)))
  }
  
  observation.df <- read.fwf(fpo, observation.fwf)
  
  if (nrow(activity.df) != nrow(observation.df) | nrow(activity.df) != nrow(subject.df) ) {
    stop(paste("The number of rows in the activity, subject or observation diles do not are not equal.",
               nrow(activity.df), nrow(subject.df), nrow(observation.df)))
  }
  
  # Add descriptive activity name
  activity.df <- mutate(activity.df, ActivityDescription = kActDesc[activity.df[,1]])
  cbind(activity.df, subject.df, observation.df )
  
}


# Main

# Constants
# #########
# Base dir relative
kBaseDataDir <- "UCI HAR Dataset"

# Steps
# #####

# Read the datasets
features <- GetFeatures(kBaseDataDir, "features.txt")

# transform the feature names to something more desriptive
descnames <- MakeDescNames(features$feature.names)

# Read the test and training datasets
data.test <- GetData(file.path(kBaseDataDir, "test"), "y_test.txt", "subject_test.txt", "X_test.txt", features$data.fmt)
data.train <- GetData(file.path(kBaseDataDir, "train"), "y_train.txt", "subject_train.txt", "X_train.txt", features$data.fmt)

# Combine the 2 datasets and name the columns
data.comb = rbind(data.test, data.train)

colnames(data.comb) <- c("Activity", "ActivityDescription", "Subject", descnames)

