

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

#setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp") # update based on the location of your data file
setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp/PI_Meeting")

### now we can import the data file 

#df <- read.csv("Minerva_WP-Experiment-Pilot_8March2024.csv") %>% # this is our Qualtrics file
df <- read.csv("WP_Qualtrics.csv") %>%
  # %>% is the pipe operator, it connects different pieces of code; we're using it to apply the below functions to the above data in sequence
  slice(-c(1, 2)) %>% # we don't need the extra header rows provided by Qualtrics so we're removing them: we use c() to create/refer to a vector of row numbers we want removed and minus sign to indicate removal
  #subset(Progress == 100 & StartDate > "2/27/24 00:00:00" & pid != "MP69") %>%
  #subset(Progress == 100 & pid %like% "MP" & StartDate > "2023-11-15 00:00:00") %>% # we can use subset() to conditionally select rows based on column values
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
                    "rme",
                    "TIPI",
                    "mission_analysis",
                    "goal_specification",
                    "strategy_formulation",
                    "monitoring_progress",
                    "systems_monitoring",
                    "team_monitoring",
                    "coordination",
                    "conflict_management",
                    "motivating",
                    "affect_management",
                    "gender",
                    "age",
                    "wp_order")))


### check that we have all of our columns

names(df)

### we don't need the practice item for the RME test so let's remove that column

df <- df %>% select(-c("rmet_practice", "gender", "UserLanguage")) # placing the minus/negative sign (-) before the column name means remove it (or keep everything except that one)


# Some Demographics -------------------------------------------------------

df$age <- as.numeric(df$age)
mean(df$age)
sd(df$age)
min(df$age)
max(df$age)

df$gender_4_TEXT <- str_remove_all(df$gender_4_TEXT," ")
df$gender_4_TEXT <- factor(df$gender_4_TEXT)
df %>% group_by(gender_4_TEXT) %>%
  summarise(no_rows = length(gender_4_TEXT))

df %>% subset(Condition == 1) %>% 
  group_by(wp_order, gender_4_TEXT) %>%
  summarise(no_rows = length(gender_4_TEXT))

df <- df %>% select(-c("gender_4_TEXT", "age"))

# Check Data Types and Item Level Statistics ------------------------------


### now let's check data types for each column

sapply(df, class) # apply class(), which returns data type, to all columns in the data frame

### by default, R read all our columns as character data type
### so we need to convert survey responses to numeric format 
### ID columns (StartDate, session, Condition, pid) are fine as they are for now

col_nums <- c(5:121) # create a vector for the column numbers we want make numeric

df[col_nums] <- sapply(df[col_nums], as.numeric)  # apply as.numeric() to a subset of columns, specifically the column numbers in the vector we just made

sapply(df, class) # make sure it worked

### now let's check the data at the column level

skim(df)

rm(col_nums) # we can remove this vector from the global environment (we don't need it anymore)

# Get Reliability for Collectivism Scale ----------------------------------


### collectivism was measured at two time points, so we check both measurements separately

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


# Get Reliability for Team Process Scales ---------------------------------

####
### transition processes
####

transition <- df %>% select(contains(c("mission_analysis",
                                       "goal_specification",
                                       "strategy_formulation"))) %>% na.omit()

alpha(transition, check.keys = TRUE)

####
### action processes
####

action <- df %>% select(contains(c("monitoring_progress",
                                   "systems_monitoring",
                                   "team_monitoring",
                                   "coordination"))) %>% na.omit()

alpha(action, check.keys = TRUE)

####
### interpersonal processes
####

interpersonal <- df %>% select(contains(c("conflict_management",
                                       "motivating",
                                       "affect_management"))) %>% na.omit()

alpha(interpersonal, check.keys = TRUE)

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


# Get Reliability for TIPI ------------------------------------------------

####
### extraversion 
####

extraversion <- df %>% select((c("TIPI_1", "TIPI_6")))

alpha(extraversion, check.keys = TRUE)

####
### agreeableness 
####

agreeableness <- df %>% select((c("TIPI_2", "TIPI_7")))

alpha(agreeableness, check.keys = TRUE)

####
### conscientious 
####

conscientious <- df %>% select((c("TIPI_3", "TIPI_8")))

alpha(conscientious, check.keys = TRUE)

####
### openness 
####

openness <- df %>% select((c("TIPI_5", "TIPI_10")))

alpha(openness, check.keys = TRUE)

####
### emotional stability 
####

emostab <- df %>% select((c("TIPI_4", "TIPI_9")))

alpha(emostab, check.keys = TRUE)


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
  ylab("") +
  theme_bw() +
  coord_flip() +
  theme(legend.position = "top",
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank())



# Median Splits -----------------------------------------------------------

df_ms <- df %>%
  mutate(rmet_ms = dplyr::case_when(
                    rmet_correct_count > median(rmet_correct_count) ~ 1,#"Highmedian",
                    rmet_correct_count < median(rmet_correct_count) ~ -1,#"Lowmedian",
                    rmet_correct_count == median(rmet_correct_count) ~ 0#"Median"
                  ),
         pc_ms = dplyr::case_when(
           collectivism_t1_mean > median(collectivism_t1_mean) ~ 1,
           collectivism_t1_mean < median(collectivism_t1_mean) ~ -1,
           collectivism_t1_mean == median(collectivism_t1_mean) ~ 0
         ),
         socdom_ms = dplyr::case_when(
           socdom_t1_mean > median(socdom_t1_mean) ~ 1,
           socdom_t1_mean < median(socdom_t1_mean) ~ -1,
           socdom_t1_mean == median(socdom_t1_mean) ~ 0
         ),
         aggdom_ms = dplyr::case_when(
           aggdom_t1_mean > median(aggdom_t1_mean) ~ 1,
           aggdom_t1_mean < median(aggdom_t1_mean) ~ -1,
           aggdom_t1_mean == median(aggdom_t1_mean) ~ 0
         )
         )

ggplot(df_ms,
       aes(x = rmet_ms)) +
  geom_bar(stat = "count") +
  theme_bw()

ggplot(df_ms,
       aes(x = pc_ms)) +
  geom_bar(stat = "count") +
  theme_bw()

ggplot(df_ms,
       aes(x = socdom_ms)) +
  geom_bar(stat = "count") +
  theme_bw()

ggplot(df_ms,
       aes(x = aggdom_ms)) +
  geom_bar(stat = "count") +
  theme_bw()

# PI Meeting --------------------------------------------------------------

team_ids <- data.frame(team_id = c(1,1,1,
                                   2,2,2,
                                   7,7,7,
                                   8,8,8,
                                   9,9,9,
                                   10,10,10),
                       pid = c("M1", "M2", "M3",
                                      "M4", "M5", "M6",
                                      "M15", "M16", "M17",
                                      "M18", "M19", "M20",
                                      "M21", "M22", "M23",
                                      "M24", "M25", "M26"))

df$pid <- str_remove_all(df$pid," ")
df_ms$pid <- str_remove_all(df_ms$pid," ")

pim_rg <- merge(team_ids,
                 df_ms,
                 by = "pid", 
                 all.x = T)



scores <- pim_rg %>% 
  select(contains(c("team_id", "pid", "_ms")))

scores$team_id <- factor(scores$team_id, 
                         levels = c("1", "2", "7", "8", "9", "10"))

mscores <- reshape2::melt(scores,
                          id.vars = c("team_id", "pid"),
                          variable.name = "Measure")


tid.labs <- c("Team 1", "Team 2", "Team 7", "Team 8", "Team 9", "Team 10")
names(tid.labs) <- c("1", "2", "7", "8", "9", "10")

mea.labs <- c("Theory of Mind", "Collectivism", "Soc. Dominance", "Agg. Dominance")
names(mea.labs) <- c("rmet_ms", "pc_ms", "socdom_ms", "aggdom_ms")

mscores$pid <- factor(mscores$pid)

ggplot(mscores,
       aes(x = value, 
           y = measure,
           fill = measure, 
           group = forcats::fct_reorder(pid, value)
           )) +
  geom_bar(position = "dodge", stat = "identity") +
  facet_grid(measure~team_id, scales = "free",
             labeller = labeller(measure = mea.labs, team_id = tid.labs)) +
  #facet_wrap(~team_id, scales = "free",
  #            labeller = labeller(team_id = tid.labs)) +
  theme_linedraw() +
  ylab("") +
  theme(legend.position = "none",
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank())

ggplot(mscores,
       aes(x = value, 
           y = Measure,
           fill = Measure, 
           group = forcats::fct_reorder(pid, value)
       )) +
  geom_bar(position = "dodge", stat = "identity", 
           colour="black", size = 0.2) +
  facet_wrap(~team_id, scales = "free",
              labeller = labeller(team_id = tid.labs)) +
  ggthemes::theme_solarized() +
  #ggthemes::theme_economist()
  ylab("") +
  xlab("Team Member Score") +
  #scale_y_discrete(breaks = c("rmet_ms", "pc_ms", "socdom_ms", "aggdom_ms")) +
  scale_fill_brewer(breaks = c("aggdom_ms", "socdom_ms", "pc_ms", "rmet_ms"),
                    palette = "Spectral",
                      labels = c("A-Dominance", "S-Dominance", "Collectivism", "ToM")) +
  scale_x_continuous(breaks = c(-1,0,1),
                     labels = c("-1" = "Low", "0" = "Mid",
                                "1" = "High")) +
  theme(legend.position = "left",
    axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank())
#
#ggplot(gather(scores, key = "measure", value, -team_id),
#       aes(value, fill = measure)) +
#  geom_histogram(bins = 5) +
#  facet_wrap(~measure,
#             scales = "free") +
#  xlab("Value") +
#  ylab("Participant Count") +
#  theme_bw() +
#  theme(legend.position = "none")
#

#im_ng <- df %>% subset(!(pid %in% pim_rg$pid))

#im_ng$wp_order <- factor(pim_ng$wp_order)
#im_ng %>% group_by(wp_order) %>%
# summarise(no_rows = length(wp_order))


#st <- pim_rg %>% subset(wp_order != "", select = c("team_id", "wp_order")) 

#cores <- pim_rg %>% 
# select(contains(c("mean", "prop", "score", "team_id")))

#gplot(gather(scores, key = "measure", value, -team_id),
#      aes(value, fill = factor(team_id), group = factor(team_id))) +
# geom_bar(position = "dodge") +
# facet_wrap(~measure,
#            scales = "free") +
# theme_bw()
  
