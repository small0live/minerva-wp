

## Qualtrics Data Prep and Summary
## Word Puzzle Experiment
## Minerva Project


# Load Packages -----------------------------------------------------------

# first we will get packages from our library

## Packages for Data Wrangling and Plotting
library(tidyverse) # a suite of packages including dplyr and ggplot2, see https://www.tidyverse.org/ 
library(data.table) # we'll use %like% from this package

## A couple packages for stats
library(skimr) # easy computation of summary stats for quick check using the skim() function
library(psych) # using alpha() for reliability


# Import and Subset Data --------------------------------------------------


### next we will set our working directory
### the directory is where our files are located - whether we are opening files in R or saving files we create in R

setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp") # update based on the location of your data file


### now we can import the data file 

df <- read.csv("Minerva_WP-Experiment-Pilot.csv") %>% # this is our Qualtrics file
  # %>% is the pipe operator, it connects different pieces of code; we're using it to apply the below functions to the above data in sequence
  slice(-c(1, 2)) %>% # we don't need the extra header rows provided by Qualtrics
  subset(Progress == 100 & pid %like% "MP" & StartDate > "2023-11-15 00:00:00") %>% # we can use subset to conditionally select rows
  # in this case the participant completed the survey and has a correctly formatted pilot subject ID, and was a SONA participant (based on exp log, SONA data collection began 11/16)
  # the & symbol indicates all conditions must be true for the row to be kept; == means we want an exact match; %like% is for regular expression matching (grep) and MP is the pattern to match
  # > means we want anything greater than, in this case any date after 11/15/2023
  select(contains(c("StartDate",  # for now, we only need session and participant info in addition to survey responses so we'll only keep those columns; contains allows us to identify all columns with a common substring (aka pattern)
                    "session",
                    "condition",
                    "pid", 
                    "collectivism",
                    "dominance",
                    "stress", 
                    "workload",
                    "rme",
                    "TIPI",
                    "mission_analysis",
                    "strategy_formulation",
                    "monitoring_progress",
                    "team_monitoring",
                    "coordination",
                    "conflict_management",
                    "motivating",
                    "goal_specification",
                    "affect_management")))


### check that we have all of our columns

names(df)

### we don't need the practice item for the RME test so let's remove that column

df <- df %>% select(-"rmet_practice") # placing the minus/negative sign (-) before the column name means remove it (or keep everything except that one)


# Check Data Types and Item Level Statistics ------------------------------


### now let's check data types for each column

sapply(df, class) # apply class(), which returns data type, to all columns in the data frame

### by default, R read all our columns as character data type
### so we need to convert survey responses to numeric format 
### ID columns (StartDate, session, Condition, pid) are fine as they are for now

col.nums <- c(5:153) # create a vector for the column numbers we want make numeric

df[col.nums] <- sapply(df[col.nums], as.numeric)  # apply as.numeric() to a subset of columns, specifically the column numbers in the vector we just made
sapply(df, class) # make sure it worked

### now let's check the data at the column level

skim(df)


# Get Reliability for Collectivism Scale ----------------------------------

### collectivism was measured at two time points, we so check both measurements separately

collectivism_t1 <- df %>% select(contains("collectivism_t1"))

alpha(collectivism_t1, check.keys = TRUE) # raw alpha is 0.87 (which is good, 0.7-0.8 is generally desired minimum level)


collectivism_t2 <- df %>% select(contains("collectivism_t2"))

alpha(collectivism_t2, check.keys = TRUE) # raw alpha is 0.88


# Get Reliability for Dominance Scales ------------------------------------

### dominance was measured at two time points, we so check both measurements separately

### this scale has two subscales, sociable dominance and aggressive dominance
### the first 8 items are sociable and the last 7 are aggressive
### we'll inspect reliability at the scale first and subscale level second


### scale level

dominance_t1 <- df %>% select(contains("dominance_t1"))

alpha(dominance_t1, check.keys = TRUE) # raw alpha is 0.82
  # something weird going on with item 15, Kalma et al. doesn't say this should be reverse coded but alpha wants to read it as such due to correlations

dominance_t2 <- df %>% select(contains("dominance_t2"))

alpha(dominance_t2, check.keys = TRUE) # raw alpha is 0.8


### social dominance scale

socialdom_t1 <- dominance_t1[,1:8]

alpha(socialdom_t1, check.keys = TRUE) # raw alpha is 0.84

socialdom_t2 <- dominance_t2[,1:8]

alpha(socialdom_t2, check.keys = TRUE) # raw alpha is 0.88


### aggressive dominance scale

aggdom_t1 <- dominance_t1[,9:15]

alpha(aggdom_t1, check.keys = TRUE) # raw alpha is 0.69 (not ideal)
  # item 15 doesn't automatically get reverse coded when we just check reliability as the subscale level, but the alpha is more acceptable if that item is dropped (0.72)

aggdom_t2 <- dominance_t2[,9:15]

alpha(aggdom_t2, check.keys = TRUE) # raw alpha is 0.72
  # interestingly, alpha doesn't improve when item 15 is dropped for time 2 measurement of the aggressive subscale



# Compute Scale and Facet/Subscale Scores ---------------------------------


