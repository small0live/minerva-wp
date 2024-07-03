

## Joggle Data Prep and Summary
## Word Puzzle Experiment
## Minerva Project



# Load Packages -----------------------------------------------------------


## Data Wrangling and Plotting
library(tidyverse)
library(data.table)


# Import Data -------------------------------------------------------------


setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp/export")


# bad_Ids <- c("MP10", "MP11", "MP13", "MP18", "MP22", "MP28") 
# for whatever reason there are duplicate IDs (with diff data values)
# having duplicate IDs for only some of the tests means we can't correctly merge data for subjects across all tests
# bc this is pilot data, we're just going to ignore them (i.e., exclude them) rather than relabel and use them

#### volt
file <- list.files(pattern = "Metrics_VOLT")
volt <- read.csv(file) %>%
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
  subset(!(Subject.Id %like% "PILOT"))


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
file <- list.files(pattern = "Metrics_PVT")
pvt <- read.csv(file) %>%
  select(Subject.Id,
         Mean.RT..ms., 
         #Median.RT..ms.,                
         Std.Dev.RT..ms.,
         Lapses) %>%
  rename(PVT_mean_RT = "Mean.RT..ms.",
         PVT_sd_RT = "Std.Dev.RT..ms.",
         PVT_Lapses = "Lapses") %>%
  subset(!(Subject.Id %like% "PILOT")) %>% drop_na()


#### nback
file <- list.files(pattern = "Metrics_NBACK")
nback <- read.csv(file) %>%
  select(Subject.Id,
         Accuracy.Score,
         Mean.RT..ms.,
         Std.Dev.RT..ms.) %>%
  rename(NBACK_Accuracy = "Accuracy.Score",
         NBACK_mean_RT = "Mean.RT..ms.",
         NBACK_sd_RT = "Std.Dev.RT..ms.") %>%
  subset(!(Subject.Id %like% "PILOT"))


#### mpt
file <- list.files(pattern = "Metrics_MPT")
mpt <- read.csv(file) %>%
  select(Subject.Id,
         Task.start,
         Task.end,
         Speed.Score,
         Feedback.Score) %>%
  rename(MPT_Start_Time = "Task.start",
         MPT_End_Time = "Task.end",
         MPT_Speed = "Speed.Score",
         MPT_Feedback = "Feedback.Score") %>%
  subset(!(Subject.Id %like% "PILOT"))


#### lot
file <- list.files(pattern = "Metrics_LOT")
lot <- read.csv(file) %>%
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
  subset(!(Subject.Id %like% "PILOT")) %>% drop_na()



#### dsst
file <- list.files(pattern = "Metrics_DSST")
dsst <- read.csv(file) %>%
  select(Subject.Id,
         Incorrect.Responses,
         Feedback.Score,
         Efficiency.Score,
         Throughput.Score..correct.min.) %>%
  rename(DSST_Incorrect_Responses = "Incorrect.Responses",
         DSST_Throughput = "Throughput.Score..correct.min.",
         DSST_Feedback = "Feedback.Score",
         DSST_Efficiency = "Efficiency.Score") %>%
  subset(!(Subject.Id %like% "PILOT"))


#### bart
file <- list.files(pattern = "Metrics_BART")
bart <- read.csv(file) %>%
  select(Subject.Id,
         Task.start,
         Task.end,
         Accuracy.Score) %>%
  rename(BART_Task_Start = "Task.start",
         BART_Task.end = "Task.end",
         BART_Accuracy_Score = "Accuracy.Score") %>%
  subset(!(Subject.Id %like% "PILOT"))


#### aim
file <- list.files(pattern = "Metrics_AIM")
aim <- read.csv(file) %>%
  select(Subject.Id,
         Task.start,
         Task.end,
         Correct.Responses,
         Incorrect.Responses,
         Feedback.Score,
         Efficiency.Score
  ) %>%
  rename(AM_Task_Start = "Task.start",
         AM_Task.end = "Task.end",
         AM_Correct_Responses = "Correct.Responses",
         AM_Incorrect_Responses = "Incorrect.Responses",
         AM_Feedback = "Feedback.Score",
         AM_Efficiency = "Efficiency.Score") %>%
  subset(!(Subject.Id %like% "PILOT") & !(is.na(Subject.Id)))



#### put all joggle data frames into list

df_list <- list(volt, pvt, nback, mpt, lot, dsst, bart, aim)


#### merge all data frames in list

joggle <- df_list %>% reduce(inner_join, by = 'Subject.Id')


#### remove individual data frames from environment
rm(volt, pvt, nback, mpt, lot, dsst, bart, aim)

### fix ID
joggle["Subject.Id"][joggle["Subject.Id"] == "M5_ActuallyM6"] <- "M6"
joggle["Subject.Id"][joggle["Subject.Id"] == "M6_ActuallyM5"] <- "M5"

# Get Test Duration for MPT, VOLT, AM, LOT, BART --------------------------


# Median Split ------------------------------------------------------------

joggle <- joggle %>%
  mutate(NBACK_ms = dplyr::case_when(
    NBACK_Accuracy >= median(NBACK_Accuracy) ~ 1,#"Highmedian",
    NBACK_Accuracy < median(NBACK_Accuracy) ~ 0#"Lowmedian"
  ),
  DSST_ms = dplyr::case_when(
    DSST_Efficiency >= median(DSST_Efficiency) ~ 1,
    DSST_Efficiency < median(DSST_Efficiency) ~ 0
  ),
  AM_ms = dplyr::case_when(
    AM_Efficiency >= median(AM_Efficiency) ~ 1,
    AM_Efficiency < median(AM_Efficiency) ~ 0
  ),
  BART_ms = dplyr::case_when(
    BART_Accuracy_Score >= median(BART_Accuracy_Score) ~ 1,
    BART_Accuracy_Score < median(BART_Accuracy_Score) ~ 0
  )
  )

joggle <- joggle %>%
  mutate(tskwrk_sum = select(., c("NBACK_ms", "DSST_ms", "AM_ms", "BART_ms")) %>% rowSums(),
         tskwrk_lvl = ifelse(tskwrk_sum >= 3, 1, 0))

# Teams for PI Meeting ----------------------------------------------------

team_ids <- data.frame(team_id = c(1,1,1,
                                   2,2,2,
                                   7,7,7,
                                   8,8,8,
                                   9,9,9,
                                   10,10,10),
                       Subject.Id = c("M1", "M2", "M3",
                                      "M4", "M5", "M6",
                                      "M15", "M16", "M17",
                                      "M18", "M19", "M20",
                                      "M21", "M22", "M23",
                                      "M24", "M25", "M26"))


pi_data <- merge(team_ids,
                 joggle,
                 by = "Subject.Id",
                 all.x = T)


scores <- pi_data %>% 
  select("team_id", 
         "Subject.Id",
         "NBACK_ms",
         "DSST_ms",
         "AM_ms",
         "BART_ms")

#ggradar::ggradar(pi_data)

mpi_data <- reshape2::melt(scores,
                          id.vars = c("team_id", "Subject.Id"),
                          variable.name = "Measure")

mpi_data$team_id <- factor(mpi_data$team_id, 
                         levels = c("1", "2", "7", "8", "9", "10"))

tid.labs <- c("Team 1", "Team 2", "Team 7", "Team 8", "Team 9", "Team 10")
names(tid.labs) <- c("1", "2", "7", "8", "9", "10")

mpi_data["value"][mpi_data["value"] == 0] <- -1

ggplot(mpi_data,
       aes(x = value, 
           y = Measure,
           fill = Measure, 
           group = forcats::fct_reorder(Subject.Id, value)
       )) +
  geom_bar(position = "dodge", stat = "identity", 
           colour="black", linewidth = 0.2) +
  geom_vline(xintercept = 0, 
             color = "black", lwd = 0.5) + 
  facet_wrap(~team_id, scales = "free",
             labeller = labeller(team_id = tid.labs)) +
  ggthemes::theme_solarized() +
  ylab("") +
  xlab("Team Member Score") +
  scale_fill_brewer(breaks = c("BART_ms", "AM_ms", "DSST_ms", "NBACK_ms"),
                    palette = "Spectral",
                    labels = c("Risk Decision Making", "Abstraction", "Scanning", "Working Memory")) +
  scale_x_continuous(breaks = c(-1,1),
                     labels = c("-1" = "Low",
                                "1" = "High")) +
  theme(legend.position = c(-0.13, 0.9),
        legend.background = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        plot.margin = margin(10, #top
                             10, # right
                             10, # bottom
                             120)) # left)

corr_data <- scores %>% select(-c("team_id", "Subject.Id"))

correlations <- corr_data %>% rstatix::cor_mat()

correlations %>% rstatix::cor_reorder() %>%
  rstatix::pull_lower_triangle() %>%
  rstatix::cor_plot(label = TRUE, font.label = list(size = 0.6))



tskwrk <- pi_data %>% 
  select(contains(c("team_id", "Subject.Id", "tskwrk_lvl")))

tskwrk$team_id <- factor(tskwrk$team_id, 
                        levels = c("1", "2", "7", "8", "9", "10"))

tid.labs <- c("Team 1", "Team 2", "Team 7", "Team 8", "Team 9", "Team 10")
names(tid.labs) <- c("1", "2", "7", "8", "9", "10")

tskwrk$Subject.Id <- factor(tskwrk$Subject.Id)

tskwrk["tskwrk_lvl"][tskwrk["tskwrk_lvl"] == 0] <- -1



ggplot(tskwrk,
       aes(y = tskwrk_lvl, 
           x = Subject.Id, 
           fill = factor(tskwrk_lvl))) +
  geom_bar(position = "dodge", stat = "identity", 
           colour="black", linewidth = 0.2) +
  geom_hline(yintercept = 0, 
             color = "black", lwd = 0.5) + 
  facet_wrap(~team_id, scales = "free_x",
             labeller = labeller(team_id = tid.labs)) +
  ggthemes::theme_solarized() +
  xlab("Team Members") +
  ylab("Overall Cognitive Profile Rating") +
  scale_fill_manual(breaks = c(-1,1),
                    values = c("#deebf7", "#08306b"),
                    labels = c("-1" = "Low", "1" = "High")) +
  scale_y_continuous(breaks = c(-1,1),
                     labels = c("-1" = "Low", "1" = "High")) +
  theme(legend.position = "none",
        legend.direction = "horizontal",
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank())


# Taskwork Potential ------------------------------------------------------


tskwrk_ptntl <- pi_data %>% select(c(team_id, Subject.Id, 
                                     NBACK_ms,
                                     DSST_ms,
                                     AM_ms,
                                     BART_ms,
                                     tskwrk_lvl))
  
tskwrk_ptntl <- tskwrk_ptntl %>%
  group_by(team_id) %>%
  mutate(WorkingMemory = mean(NBACK_ms),
         Scanning = mean(DSST_ms),
         Abstraction = mean(AM_ms),
         RiskDM = mean(BART_ms)) %>%
  mutate(Memory_potential = ifelse(WorkingMemory >= 0.5, 1, 0),
         Scan_potential = ifelse(Scanning >= 0.5, 1, 0),
         Abstract_potential = ifelse(Abstraction >= 0.5, 1, 0),
         RiskDM_potential = ifelse(RiskDM >= 0.5, 1, 0)) %>%
  rename(pid = "Subject.Id")

# Visualize Distributions -------------------------------------------------


#### efficiency scores

efficiency <- joggle %>% select(contains(c("Subject.Id", "Efficiency")))

ggplot(gather(efficiency, 
              key = "test", 
              value = "measurement", 
              -Subject.Id),
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
  facet_wrap(~Subject.Id) +
  xlab("Reaction Time") +
  ylab("Count") +
  theme_bw() +
  theme(legend.position = "none")


#### accuracy

accuracy <- joggle %>% select(contains(c("Subject.Id", "Accuracy")))

ggplot(gather(accuracy, key = "test", value = "measurement", -Subject.Id),
       aes(measurement, fill = test)) +
  geom_histogram(binwidth = 100) +
  facet_wrap(~Subject.Id) +
  xlab("Accuracy") +
  ylab("Count") +
  theme_bw() +
  theme(legend.position = "none")

