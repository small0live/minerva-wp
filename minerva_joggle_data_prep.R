

## Joggle Data Prep and Summary
## Word Puzzle Experiment
## Minerva Project



# Load Packages -----------------------------------------------------------


## Data Wrangling and Plotting
library(tidyverse)


# Import Data -------------------------------------------------------------


setwd("~/Downloads/export")


bad_Ids <- c("MP10", "MP11", "MP13", "MP18", "MP22", "MP28") 
# for whatever reason there are duplicate IDs (with diff data values)
# having duplicate IDs for only some of the tests means we can't correctly merge data for subjects across all tests
# bc this is pilot data, we're just going to ignore them (i.e., exclude them) rather than relabel and use them

#### volt

volt <- read.csv("Metrics_VOLT_2023-11-28T21_20_09.csv") %>%
  select(Subject.Id,
         Task.start,
         Task.end,
         Mean.RT..ms., 
         #Median.RT..ms.,                
         Std.Dev.RT..ms.,
         Efficiency.Score,
         Feedback.Score) %>%
  rename(VOLT_Start_Time = "Task.start",
         VOLT_End_Time = "Task.end",
         VOLT_mean_RT = "Mean.RT..ms.",
         VOLT_sd_RT = "Std.Dev.RT..ms.",
         VOLT_Efficiency = "Efficiency.Score",
         VOLT_Feedback = "Feedback.Score") %>%
  subset(!(Subject.Id %in% bad_Ids))


#volt[c('date', 'VOLT_start_time')] <- str_split_fixed(volt$Task.start, 'T', 2)
#volt[c('date', 'VOLT_end_time')] <- str_split_fixed(volt$Task.end, 'T', 2)
#
#df$time <- gsub("\\..*", "", df$time)
#
#df$time_format <- strptime(df$time, "%H:%M:%S")
#
#df <- df %>% 
#  group_by(stageId) %>%
#  mutate(diffSecs = cumsum(as.numeric(difftime(time_format, lag(time_format, 1, default = time_format[1]), unit = "secs"))),
#         diffMins = cumsum(as.numeric(difftime(time_format, lag(time_format, 1, default = time_format[1]), unit = "mins"))))

#### pvt

pvt <- read.csv("Metrics_PVT_2023-11-28T21_20_09.csv") %>%
  select(Subject.Id,
         Mean.RT..ms., 
         #Median.RT..ms.,                
         Std.Dev.RT..ms.,
         Lapses) %>%
  rename(PVT_mean_RT = "Mean.RT..ms.",
         PVT_sd_RT = "Std.Dev.RT..ms.",
         PVT_Lapses = "Lapses") %>%
  subset(!(Subject.Id %in% bad_Ids))


#### nback

nback <- read.csv("Metrics_NBACK_2023-11-28T21_20_09.csv") %>%
  select(Subject.Id,
         Accuracy.Score,
         Mean.RT..ms.,
         Std.Dev.RT..ms.) %>%
  rename(NBACK_Accuracy = "Accuracy.Score",
         NBACK_mean_RT = "Mean.RT..ms.",
         NBACK_sd_RT = "Std.Dev.RT..ms.") %>%
  subset(!(Subject.Id %in% bad_Ids))


#### mpt

mpt <- read.csv("Metrics_MPT_2023-11-28T21_20_09.csv") %>%
  select(Subject.Id,
         Task.start,
         Task.end,
         Speed.Score,
         Feedback.Score) %>%
  rename(MPT_Start_Time = "Task.start",
         MPT_End_Time = "Task.end",
         MPT_Speed = "Speed.Score",
         MPT_Feedback = "Feedback.Score") %>%
  subset(!(Subject.Id %in% bad_Ids))


#### lot

lot <- read.csv("Metrics_LOT_2023-11-28T21_20_09.csv") %>%
  select(Subject.Id,
         Task.start,
         Task.end,
         Mean.RT..ms., 
         #Median.RT..ms.,                
         Std.Dev.RT..ms.,
         Correct.Responses,
         Incorrect.Responses) %>%
  rename(LOT_Start_Time = "Task.start",
         LOT_End_Time = "Task.end",
         LOT_mean_RT = "Mean.RT..ms.",
         LOT_sd_RT = "Std.Dev.RT..ms.",
         LOT_Correct_Responses = "Correct.Responses",
         LOT_Incorrect_Responses = "Incorrect.Responses") %>%
  subset(!(Subject.Id %in% bad_Ids))



#### dsst

dsst <- read.csv("Metrics_DSST_2023-11-28T21_20_09.csv") %>%
  select(Subject.Id,
         Incorrect.Responses,
         Feedback.Score,
         Efficiency.Score,
         Throughput.Score..correct.min.) %>%
  rename(DSST_Incorrect_Responses = "Incorrect.Responses",
         DSST_Throughput = "Throughput.Score..correct.min.",
         DSST_Feedback = "Feedback.Score",
         DSST_Efficiency = "Efficiency.Score") %>%
  subset(!(Subject.Id %in% bad_Ids))


#### bart

bart <- read.csv("Metrics_BART_2023-11-28T21_20_09.csv") %>%
  select(Subject.Id,
         Task.start,
         Task.end,
         Accuracy.Score) %>%
  rename(BART_Task_Start = "Task.start",
         BART_Task.end = "Task.end",
         BART_Accuracy_Score = "Accuracy.Score") %>%
  subset(!(Subject.Id %in% bad_Ids))


#### aim

aim <- read.csv("Metrics_AIM_2023-11-28T21_20_09.csv") %>%
  select(Subject.Id,
         Task.start,
         Task.end,
         Correct.Responses,
         Incorrect.Responses,
         Feedback.Score,
         Efficiency.Score
  ) %>%
  rename(AIM_Task_Start = "Task.start",
         AIM_Task.end = "Task.end",
         AIM_Correct_Responses = "Correct.Responses",
         AIM_Incorrect_Responses = "Incorrect.Responses",
         AIM_Feedback = "Feedback.Score",
         AIM_Efficiency = "Efficiency.Score")  %>%
  subset(!(Subject.Id %in% bad_Ids))



#### put all joggle data frames into list

df_list <- list(volt, pvt, nback, mpt, lot, dsst, bart, aim)


#### merge all data frames in list

joggle <- df_list %>% reduce(inner_join, by = 'Subject.Id')


#### remove individual data frames from environment
rm(volt, pvt, nback, mpt, lot, dsst, bart, aim)


# Get Test Duration for MPT, VOLT, AM, LOT, BART --------------------------




# Visualize Distributions -------------------------------------------------

#### efficiency scores

efficiency <- joggle %>% select(contains(c("Subject.Id", "Efficiency")))

ggplot(gather(efficiency, key = "test", value = "measurement", -Subject.Id),
       aes(measurement, fill = test)) +
  geom_histogram(binwidth = 100) +
  facet_wrap(~test) +
  xlab("Efficiency Score") +
  ylab("Count") +
  theme_bw() +
  theme(legend.position = "none")


#### mean reaction time

reaction <- joggle %>% select(contains(c("Subject.Id", "mean_RT")))

ggplot(gather(reaction, key = "test", value = "measurement", -Subject.Id),
       aes(measurement, fill = test)) +
  geom_histogram(binwidth = 1000) +
  facet_wrap(~test) +
  xlab("Reaction Time") +
  ylab("Count") +
  theme_bw() +
  theme(legend.position = "none")

