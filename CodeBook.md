# getdata-033 Code Book

This code book describes the steps executed by the `run_analysys.R` script
as set out in the getdata-033 Project [Project](https://class.coursera.org/getdata-033)

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Data

### Test and Training Data

Each of the 2 sets of data are made up of 1 files in their respective folders.

Replace `xxx` below with `test` or `train`.

`y_xxx.txt` - a single column file that contains the numeric activity 1:6
relating to corresponding record in the observations file.

`X_xxx.txt` - a set of 561 observations corresponding to the activity in the activity
file. This file is, by inspection, a set of 561 measurements each of which is
16 character wide in the `X_xxx.txt` file. The observation file is a fixed width
file of 8976 characters. This fixed field width and fixed record width property
of the observation file is used to advantage to extract only the relevant mean
and standard deviation data from each row.

`Subject_xxx.txt` - a single column file that contains the numeric subject
number 1:30 relating to corresponding record in the observations file.

Each of these 3 files in their respective directories, contains the same number
of rows and there are no headers in any of the files.

### Features Data

The `UCI HAR Dataset` directory contains the files `features.txt` and `feature_info.txt`.

The `feature.txt` file is a list of the 561 observations found in the `X_xxx.txt`
test and training files.

## Script processing

The `run_analysis` script meets requirements 1 through 4 of the project objectives
by performing the following operations:-

### GetFeatures <- function (base.dir, features.filename)

The `GetFeatures` function is called to process the `features.txt` file.

To meet objective 2, the `features.txt` file is searched (using a regular expression)
to discover the feature names that contain `mean()` or `std()`. It is only these
features that will be extracted to the output data frame.

Using the fixed width property of the observations file `X_xxx.txt` the `GetFeatures`
function also constructs a vector describing the fields that will be extracted from
each observation. This vector takes the form `c(16,16,16,16,16,16,-16,...)` and
is passed to the R `read.fwf()` function when the observations are read.

`GetFeatures` returns a list containing a `feature.names` vector and a `data.fmt`
vector that describes how to read the fixed width observations file to return only
the relevant features.

* `feature.names` - a character vector of the names discovered by `GetFeatures`
* `data.fmt` - a numeric vector that is used as input to the `read.fwf()` to only extract the desired data.

### MakeDescNames <- function(feature.names)

The `MakeDescNames` function is next called passing the `feature.names` vector returned by `GetFeatures`

This function transforms the input feature names into more descriptive names by applying
the replacements:

* all "-" characters are replaced by "_"
* `mean()` and `std()` are replaced by `Mean` and `StdDev` respectively
* Leading `f` and leading `t` in the feature names are replaced by `Freq_` and `Time_`

`MakeNames` returns the vector of descriptive names resulting from the above transformations.

### GetData <- function(base.dir, activty.filename, subject.filename, observation.filename, observation.fwf)

The `GetData` function is called to read the activity, subject and observation files from
`base.dir` directory.

The activity and subject files are read using the R `read.table()` function whilst
the observations file is read using the R `read.fwf()` function using the passed `observation.fwf`
vector to ensure that only the relevant features are read from the observations file.

The analysis data is mutated to add a column that contains descriptive text for the activity
corresponding to the numeric value in the `y_xxx.txt` file. These numeric values are mapped as

1 "Walking"
2 "Walking_Upstairs"
3 "Walking_Downstairs"
4 "Sitting"
5 "Standing"
6 "Laying"

`GetData` performs a `cbind()` to bind the activity, subject and observation data
frame. The resulting `cbind()` is returned.

The `run_analysis.R` script calls `GetData` once for each of the test and training
sets of data.

### Combining and applying descriptive column names

Finally, the `run_analysis,R` script combine the test and training data frames
using `rbind()` and applies the descriptive set of column names using `colnames()`
against the combined set.

Once the script is executed the resulting combined data frame can be examined using
`head(data.comb)` or `tail(data.comb)`.

### Tidy Data set

Plain ran out of time!
