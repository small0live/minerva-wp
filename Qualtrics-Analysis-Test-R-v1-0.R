## Minerva Puzzle Pilot - Qualtrics Data Prep & Summary
## Word Puzzle Experiment
## Minerva Project
## Nathan A. Sonnenfeld
## Version 1.0
## Last Updated: 2023 Dec 10


############## STEP 0: FUNCTIONS & OPTIONS ############## 

### Load Packages --------------------------------------

# in R nomenclature, what you are loading is the package - the collection of functions, data, etc. 
# the library is where the package is stored
# so you load a package, not a library
# see https://stackoverflow.com/questions/26900228/what-is-the-difference-between-a-library-and-a-package-in-r 

## Data Wrangling
library(tidyverse)
#library(dplyr) redundant - dplyr is bundled into tidyverse, so it's not necessary to load it separately

## Plotting
library(ggplot2)


### Import and Subset Data --------------------------------------------------


############## STEP 1: BRING IN DATA ############## 

## Set working directory / folder
## setwd('set path of data')
## Import data

setwd("C:/Users/sonne/Desktop/Minerva/Data Analysis/Data-Qualtrics/Data-Pilot-23Dec")


############## STEP 2: PREP DATA ############## 


### FILTER OUT INCOMPLETES & DUPLICATES ##

## Identify incomplete surveys (not timer info though)

filter_frame <- read.csv("minerva-puzzle-pilot-data-qualtrics-clean1.csv") %>%
  select(pid,
         session,
         Condition,
         Finished) %>%
  rename(#pid = "pid", # these don't need to be renamed, you haven't changed anything about them? 
         #session = "session",
         condition = "Condition", # I haven't commented this out because you are using the lower case in your code, but generally this is unnecessary. I rename if the existing column name is not clear and/or can be confused with other vars. 
         finished = "Finished") %>%
mutate(finished = as.numeric(finished)) # Convert 'finished' to numeric

## Remove rows where specific columns are NA
filter_frame <- filter_frame %>% 
  filter(!is.na(finished))

## Check the structure of the data frame
str(filter_frame)

## Check the first few rows of the data frame
head(filter_frame)

## Create a subset where 'finished' is 0

missingdata_pids <- filter(filter_frame, finished == 0)

## Print the subset
print(missingdata_pids)
nrow(missingdata_pids)

# Find the duplicated pids
duplicated_pids <- filter_frame[duplicated(filter_frame$pid), "pid"]

# Print the duplicated pids
print(duplicated_pids)
nrow(duplicated_pids)

# Create a data frame from duplicated pids
duplicated_pids_df <- data.frame(pid = duplicated_pids)
  
## Combine missing data and duplicated pids into bad_pids
bad_pids <- bind_rows(missingdata_pids, duplicated_pids_df)
bad_pids <- distinct(bad_pids, pid) # Remove any duplicates in the combined set

# Print bad_pid list for use in pilotdata_frame
print(bad_pids)

### CREATE PILOT DATA FRAME ###

bad_pid_list <- c("999", "9999", "Ooo", "oli1", "oli2", "M101", "M103", "MP11") 

pilotdata_frame <- read.csv("minerva-puzzle-pilot-data-qualtrics-clean1.csv") %>%
  select(contains(c("pid", "session", "Condition",  
                    "age",
                    "gender",
                    #"race_ethnicity",
                    #"class_standing",
                    #"major",
                    "collectivism", # you can use contains to identify all columns with a common substring
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
                    "affect_management"))) %>%
  rename(#pid = "pid",
         #session = "session",
         condition = "Condition") %>%
  subset(!(pid %in% bad_pid_list))
#         
#         # Collectivism  T1- Needs to be scored etc.
#         collectivism_t1_1, collectivism_t1_2, collectivism_t1_3,
#         collectivism_t1_4, collectivism_t1_5, collectivism_t1_6,
#         collectivism_t1_7, collectivism_t1_8, collectivism_t1_9,
#         collectivism_t1_10, collectivism_t1_11, collectivism_t1_12,
#         collectivism_t1_13, collectivism_t1_14, collectivism_t1_15,
#         
#         # Dominance T1- Needs to be scored etc.
#         dominance_t1_1, dominance_t1_2, dominance_t1_3,
#         dominance_t1_4, dominance_t1_5, dominance_t1_6,
#         dominance_t1_7, dominance_t1_8, dominance_t1_9,
#         dominance_t1_10, dominance_t1_11, dominance_t1_12,
#         dominance_t1_13, dominance_t1_14, dominance_t1_15,
#         
#         # Stress & Workload - Needs to be scored etc.
#         stress,
#         workload,
#         
#         # ToM / RMET
#         rme1, rme2, rme3, rme4, rme5, rme6, rme7, rme8,
#         rme9, rme10, rme11, rme12, rme13, rme14, rme15, rme16,
#         rme17, rme18, rme19, rme20, rme21, rme22, rme23, rme24,
#         rme25, rme26, rme27, rme28, rme29, rme30, rme31, rme32,
#         rme33, rme34, rme35, rme36,
#
#         # Demographics
#         age,
#         gender,
#         race_ethnicity,
#         class_standing,
#         major,
#         
#         # Collectivism  T2 - Needs to be scored etc.
#         collectivism_t2_1, collectivism_t2_2, collectivism_t2_3,
#         collectivism_t2_4,	collectivism_t2_5, collectivism_t2_6,
#         collectivism_t2_7,	collectivism_t2_8, collectivism_t2_9,
#         collectivism_t2_10, collectivism_t2_11, collectivism_t2_12,
#         collectivism_t2_13, collectivism_t2_14, collectivism_t2_15,
#         
#         # Dominance  T2 - Needs to be scored etc.
#         dominance_t2_1,	dominance_t2_2,	dominance_t2_3,
#         dominance_t2_4,	dominance_t2_5,	dominance_t2_6,
#         dominance_t2_7,	dominance_t2_8,	dominance_t2_9,
#         dominance_t2_10,	dominance_t2_11, dominance_t2_12,
#         dominance_t2_13,	dominance_t2_14, dominance_t2_15,
#         
#         # TIPI - Needs to be scored etc.
#         TIPI_1,	TIPI_2,	TIPI_3,	TIPI_4,	TIPI_5,
#         TIPI_6,	TIPI_7,	TIPI_8,	TIPI_9,	TIPI_10,
#         
#         # Mission Analysis
#         mission_analysis_1,	mission_analysis_2,
#         mission_analysis_3, mission_analysis_4,
#         
#         # Goal Specification
#         goal_specification_1,	goal_specification_2,
#         goal_specification_3,	goal_specification_4,
#         
#         # Strategy Formulation
#         strategy_formulation_1, strategy_formulation_2,
#         strategy_formulation_3,	strategy_formulation_4,
#         strategy_formulation_5,
#         
#         # Monitoring Progress
#         monitoring_progress_1,	monitoring_progress_2,
#         monitoring_progress_3,	monitoring_progress_4,
#         
#         # Systems Monitoring
#         systems_monitoring_1,	systems_monitoring_2,
#         systems_monitoring_3,	systems_monitoring_4,
#         systems_monitoring_5,
#         
#         # Team Monitoring
#         team_monitoring_1,	team_monitoring_2,	team_monitoring_3,
#         team_monitoring_4,	team_monitoring_5,
#         
#         # Coordination
#         coordination_1, coordination_2,	coordination_3,
#         coordination_4,
#         
#         # Conflict Management
#         conflict_management_1,	conflict_management_2,
#         conflict_management_3,	conflict_management_4,
#         conflict_management_5,
#         
#         # Motivating
#         motivating_1, motivating_2,	motivating_3,
#         motivating_4, motivating_5,
#         
#         # Affect Management
#         affect_management_1,	affect_management_2, affect_management_3,
#         affect_management_4,	affect_management_5) %>%

## Check the structure of the data frame
  str(pilotdata_frame)

## Check the first few rows of the data frame
#  head(pilotdata_frame)

### SCORING MEASURES IN DATA FRAME ###

#TBD

############## STEP 3: VISUALIZATION ############## 

#TBD

############## STEP 4: STATS ############## 

### BASIC DESCRIPTIVES

### Age
  pilotdata_frame %>%
    summarise(
      Mean = mean(age, na.rm = TRUE),
      Median = median(age, na.rm = TRUE),
      SD = sd(age, na.rm = TRUE),
      Var = var(age, na.rm = TRUE),
    )

  ### Stress
  pilotdata_frame %>%
    summarise(
      Mean = mean(stress, na.rm = TRUE),
      Median = median(stress, na.rm = TRUE),
      SD = sd(stress, na.rm = TRUE),
      Var = var(stress, na.rm = TRUE),
    )

  
  ### Workload
  pilotdata_frame %>%
    summarise(
      Mean = mean(workload, na.rm = TRUE),
      Median = median(workload, na.rm = TRUE),
      SD = sd(workload, na.rm = TRUE),
      Var = var(workload, na.rm = TRUE),
    )
  
## BASIC DESCRIPTIVES BY CONDITION

  ## Age by Condition
  pilotdata_frame %>%
    group_by(condition) %>%
    reframe(
      Mean = mean(age, na.rm = TRUE),
      Median = median(age, na.rm = TRUE),
      SD = sd(age, na.rm = TRUE),
      Var = var(age, na.rm = TRUE),
    )

  ## Stress by Condition
  pilotdata_frame %>%
    group_by(condition) %>%
    reframe(
      Mean = mean(stress, na.rm = TRUE),
      Median = median(stress, na.rm = TRUE),
      SD = sd(stress, na.rm = TRUE),
      Var = var(stress, na.rm = TRUE),
    )
  
  ### Workload by Condition
  pilotdata_frame %>%
    group_by(condition) %>%
    reframe(
      Mean = mean(workload, na.rm = TRUE),
      Median = median(workload, na.rm = TRUE),
      SD = sd(workload, na.rm = TRUE),
      Var = var(workload, na.rm = TRUE),
    )



  
  