

## Qualtrics Data Prep and Summary
## Word Puzzle Experiment
## Minerva Project


# Load Packages -----------------------------------------------------------


# first we will get necessary packages from our library

## Packages for data wrangling and plotting
library(tidyverse) # a suite of packages including dplyr and ggplot2, see https://www.tidyverse.org/ 
library(data.table) # we'll use %like% from this package

## A couple packages for stats
library(skimr) # easy computation of summary stats for quick check using the skim() function
library(psych) # using alpha() for reliability assessment


# Import and Subset Data --------------------------------------------------


### next we will set our working directory
### the directory is where our files are located - whether we are opening files in R or saving files we create in R

setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp") # update based on the location of your data file


### now we can import the data file 

df <- read.csv("Minerva_WP-Experiment-Pilot.csv") %>% # this is our Qualtrics file
  # %>% is the pipe operator, it connects different pieces of code; we're using it to apply the below functions to the above data in sequence
  slice(-c(1, 2)) %>% # we don't need the extra header rows provided by Qualtrics so we're removing them: we use c() to create/refer to a vector of row numbers we want removed and minus sign to indicate removal
  subset(Progress == 100 & pid %like% "MP" & StartDate > "2023-11-15 00:00:00") %>% # we can use subset() to conditionally select rows based on column values
  # in this case the participant completed the survey and has a correctly formatted pilot subject ID, and was a SONA participant (based on exp log, SONA data collection began 11/16)
  # the & symbol indicates all conditions must be true for the row to be kept; == means we want an exact match; %like% is for regular expression matching (grep) and MP is the pattern to match
  # > means we want anything greater than, in this case any date after 11/15/2023
  select(contains(c("StartDate",  # contains() allows us to identify all columns with a common substring (aka pattern); starts_with() is an alternative that checks the beginning of the string whereas contains() checks the entire string
                    "session", # for now, we only need session and participant info in addition to survey responses so we'll only keep those columns
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

col_nums <- c(5:153) # create a vector for the column numbers we want make numeric

df[col_nums] <- sapply(df[col_nums], as.numeric)  # apply as.numeric() to a subset of columns, specifically the column numbers in the vector we just made
sapply(df, class) # make sure it worked

### now let's check the data at the column level

skim(df)

rm(col_nums) # remove vector from global environment (we don't need it anymore)


# Get Reliability for Collectivism Scale ----------------------------------


### collectivism was measured at two time points, we so check both measurements separately

### time 1 measurement

collectivism_t1 <- df %>% select(contains("collectivism_t1"))

alpha(collectivism_t1, check.keys = TRUE) # raw alpha is 0.87 (which is good, 0.7-0.8 is generally desired minimum level)
  # from docs: for check.keys, if TRUE, then find the first principal component and reverse key items with negative loadings. Give a warning if this happens.

### time 2 measurement

collectivism_t2 <- df %>% select(contains("collectivism_t2"))

alpha(collectivism_t2, check.keys = TRUE) # raw alpha is 0.88

rm(collectivism_t1, collectivism_t2)

# Get Reliability for Dominance Scales ------------------------------------

### dominance was measured at two time points, we so check both measurements separately

### this scale has two subscales, sociable dominance and aggressive dominance
### the first 8 items are sociable and the last 7 are aggressive
### we'll inspect reliability at the scale first and subscale level second

####
### overall scale level
####

### time 1 measurement

dominance_t1 <- df %>% select(contains("dominance_t1"))

alpha(dominance_t1, check.keys = TRUE) # raw alpha is 0.82
  # something weird going on with item 15, Kalma et al. doesn't say this should be reverse coded but alpha wants to read it as such due to correlations

### time 2 measurement

dominance_t2 <- df %>% select(contains("dominance_t2"))

alpha(dominance_t2, check.keys = TRUE) # raw alpha is 0.8


####
### social dominance scale
####

socialdom_t1 <- dominance_t1[,1:8]

alpha(socialdom_t1, check.keys = TRUE) # raw alpha is 0.84

socialdom_t2 <- dominance_t2[,1:8]

alpha(socialdom_t2, check.keys = TRUE) # raw alpha is 0.88


####
### aggressive dominance scale
####

aggdom_t1 <- dominance_t1[,9:15]

alpha(aggdom_t1, check.keys = TRUE) # raw alpha is 0.69 (not ideal)
  # item 15 doesn't automatically get reverse coded when we check reliability as the subscale level, but the alpha is more acceptable if that item is dropped (0.72)

aggdom_t2 <- dominance_t2[,9:15]

alpha(aggdom_t2, check.keys = TRUE) # raw alpha is 0.72
  # interestingly, alpha doesn't improve when item 15 is dropped for time 2 measurement of the aggressive subscale


rm(socialdom_t1, socialdom_t2, aggdom_t1, aggdom_t2, dominance_t1, dominance_t2)

# Reverse Score Items -----------------------------------------------------


### TIPI: TIPI_2, TIPI_4, TIPI_6, TIPI_8, and TIPI_10 need to be reverse coded

tipi_r <- c("TIPI_2", "TIPI_4", "TIPI_6", "TIPI_8", "TIPI_10") # column names for reverse coded items 
tipi_r <- which( colnames(df) %in% tipi_r ) # create a vector for the column numbers we want to reverse code based on column names


### check out the values, we'll check again after reverse coding

df[tipi_r] 

### reverse code values

df[tipi_r] <- sapply(df[tipi_r], FUN = function(foo) recode(foo, # foo is placeholder for a value that can change, we're using it for the set of columns being altering
                                                            "1" = 7, 
                                                            "2" = 6, 
                                                            "3" = 5, 
                                                            "4" = 4, 
                                                            "5" = 3, 
                                                            "6" = 2, 
                                                            "7" = 1))

### check out the values to make sure it worked

df[tipi_r]

rm(tipi_r) # remove vector from global environment (we don't need it anymore)


# Compute Scale and Facet/Subscale Scores ---------------------------------

df <- df %>%
  mutate(collectivism_t1_mean = select(., starts_with("collectivism_t1_")) %>% rowMeans(),
         collectivism_t2_mean = select(., starts_with("collectivism_t2_")) %>% rowMeans(),
         socdom_t1_mean = select(., dominance_t1_1:dominance_t1_8) %>% rowMeans(),
         socdom_t2_mean = select(., dominance_t2_1:dominance_t1_8) %>% rowMeans(),
         aggdom_t1_mean = select(., dominance_t1_9:dominance_t2_15) %>% rowMeans(),
         aggdom_t2_mean = select(., dominance_t2_9:dominance_t2_15) %>% rowMeans(),
         TIPI_Extraversion_score = select(., c("TIPI_1", "TIPI_6")) %>% rowMeans(),
         TIPI_Agreeableness_score = select(., c("TIPI_2", "TIPI_7")) %>% rowMeans(),
         TIPI_Conscientious_score = select(., c("TIPI_3", "TIPI_8")) %>% rowMeans(),
         TIPI_Openness_score = select(., c("TIPI_5", "TIPI_10")) %>% rowMeans(),
         TIPI_EmotionalStability_score = select(., c("TIPI_4", "TIPI_9")) %>% rowMeans(),
         rmet_correct_count = select(., starts_with("rme")) %>% rowSums(),
         rmet_correct_prop = rmet_correct_count/36
         )


# TIPI Scale Items
# Extraversion: TIPI_1, TIPI_6
# Agreeableness TIPI_2, TIPI_7
# Conscientiousness: TIPI_3, TIPI_8
# Openness to Experiences: TIPI_5, TIPI_10
# Emotional Stability: TIPI_4, TIPI_9



# Save Data ---------------------------------------------------------------

#write.csv(df,
#          "Minerva_WP-Experiment-Pilot_withScores.csv",
#          row.names = F)

# Visualize Means ---------------------------------------------------------

df$Condition <- recode(df$Condition, "1" = "Nominal Group", "2" = "Real Group")

scores <- df %>% select(contains(c("mean", "prop", "score", "Condition")))

ggplot(gather(scores, key = "measure", value, -Condition),
       aes(value, fill = measure)) +
  geom_histogram(bins = 5) +
  facet_wrap(~measure,
             scales = "free") +
  xlab("Value") +
  ylab("Participant Count") +
  theme_bw() +
  theme(legend.position = "none")

ggplot(gather(scores, key = "measure", value, -Condition),
       aes(value, fill = Condition, group = Condition)) +
  geom_boxplot() +
  facet_wrap(~measure,
             scales = "free") +
  xlab("Value") +
  ylab("Participant Count") +
  theme_bw() +
  theme(legend.position = "top")





