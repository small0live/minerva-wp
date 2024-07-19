

## Word Puzzle Experiment
## Minerva Project


# Load Packages -----------------------------------------------------------


library(tidyverse) # a suite of packages including dplyr and ggplot2, see https://www.tidyverse.org/ 
library(data.table) # we'll use %like% from this package


# Import Qualtrics Data ---------------------------------------------------


# tell R where the data is
setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp/data") # this should be updated to match where your data is stored

# get the data 
df <- read.csv("WP_Qualtrics.csv") %>%
  slice(-c(1, 2)) %>% # remove extra header rows
  select(contains(c("StartDate", # keep only columns we want to use
                    "session",
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
                    "wp_order"))) %>% 
  select(-c("rmet_practice", "gender", "UserLanguage")) %>% # remove some columns we don't need
  mutate(Condtion_categorical = ifelse(Condition == 1, "Nominal Group", "Real Group"), 
         wp_order = ifelse(wp_order == "", NA, paste0(wp_order))) %>% # replace empty cells with NA in word puzzle order column 
  group_by(session) %>%
  fill(wp_order, .direction = 'updown') %>% # fill in missing puzzle order info for some RG participants
  ungroup() %>%
  select(c(1:3,159,158,4:157)) # quick reordering using column number


# Get Some Demographics ---------------------------------------------------


####
# AGE
####

# convert to numeric data type
df$age <- as.numeric(df$age)

# get summary stats
age_stats <- df %>%
  select(age) %>%
  summarise_at(vars(age), list(Min = min, Mean = mean, Max = max, Sd = sd))

####
# GENDER
####

# remove any extra white space from participant response
df$gender_4_TEXT <- str_remove_all(df$gender_4_TEXT," ")

# convert to factor data type
df$gender_4_TEXT <- factor(df$gender_4_TEXT)

# get gender counts across entire sample
gender_counts <- df %>% group_by(gender_4_TEXT) %>%
  mutate(gender_4_TEXT = ifelse(gender_4_TEXT == "Male", "Man", 
                                ifelse(gender_4_TEXT == "Female", "Woman", paste0(gender_4_TEXT)))) %>%
  summarise(n = length(gender_4_TEXT)) %>%
  rename(Gender = "gender_4_TEXT")

# get gender counts by condition
gc_bycondition <- df %>% group_by(Condtion_categorical, gender_4_TEXT) %>%
  mutate(gender_4_TEXT = ifelse(gender_4_TEXT == "Male", "Man", 
                                ifelse(gender_4_TEXT == "Female", "Woman", paste0(gender_4_TEXT)))) %>%
  summarise(n = length(gender_4_TEXT)) %>%
  rename(Gender = "gender_4_TEXT")

# remove columns we no longer need
df <- df %>% select(-c("gender_4_TEXT", "age"))


# Prep Data for Aggregation -----------------------------------------------


####
# Convert Data Types
###

# create a vector for the column numbers we want make numeric
col_nums <- c(7:156)

# apply as.numeric() to those columns then print out data type to check
df[col_nums] <- sapply(df[col_nums], as.numeric)
sapply(df, class)

# remove vector we no longer need
rm(col_nums)


####
# Reverse score TIPI items
####

# TIPI: TIPI_2, TIPI_4, TIPI_6, TIPI_8, and TIPI_10 need to be reverse coded
tipi_r <- c("TIPI_2", "TIPI_4", "TIPI_6", "TIPI_8", "TIPI_10") # column names for reverse coded items 
tipi_r <- which( colnames(df) %in% tipi_r ) # create a vector for the column numbers we want to reverse code based on column names

# check out the values
df[tipi_r] 

# reverse code values
df[tipi_r] <- sapply(df[tipi_r], FUN = function(foo) dplyr::recode(foo, "1" = 7, "2" = 6, "3" = 5, "4" = 4, "5" = 3, "6" = 2, "7" = 1))

# check to make sure it worked
df[tipi_r]

# remove vector we no longer need
rm(tipi_r)


# Compute Scale and Facet/Subscale Scores ---------------------------------

df <- df %>%
  mutate(collectivism_t1_mean = select(., starts_with("collectivism_t1_")) %>% rowMeans(),
         collectivism_t2_mean = select(., starts_with("collectivism_t2_")) %>% rowMeans(),
         socdom_t1_mean = select(., dominance_t1_1:dominance_t1_8) %>% rowMeans(),
         socdom_t2_mean = select(., dominance_t2_1:dominance_t1_8) %>% rowMeans(),
         aggdom_t1_mean = select(., dominance_t1_9:dominance_t2_15) %>% rowMeans(),
         aggdom_t2_mean = select(., dominance_t2_9:dominance_t2_15) %>% rowMeans(),
         overalldom_t1_mean = select(., starts_with("dominance_t1_")) %>% rowMeans(),
         overalldom_t2_mean = select(., starts_with("dominance_t1_")) %>% rowMeans(),
         TIPI_Extraversion_score = select(., c("TIPI_1", "TIPI_6")) %>% rowMeans(),
         TIPI_Agreeableness_score = select(., c("TIPI_2", "TIPI_7")) %>% rowMeans(),
         TIPI_Conscientious_score = select(., c("TIPI_3", "TIPI_8")) %>% rowMeans(),
         TIPI_Openness_score = select(., c("TIPI_5", "TIPI_10")) %>% rowMeans(),
         TIPI_EmotionalStability_score = select(., c("TIPI_4", "TIPI_9")) %>% rowMeans(),
         rmet_correct_count = select(., starts_with("rme")) %>% rowSums(),
         rmet_correct_prop = rmet_correct_count/36,
         teamprocess_mean = select(., starts_with(c("mission_analysis", "goal_specification", 
                                                    "strategy_formulation", "monitoring_progress", 
                                                    "systems_monitoring", "team_monitoring", 
                                                    "coordination", "conflict_management", 
                                                    "motivating", "affect_management"))) %>% rowMeans()
         )



# Save Individual Level Data ----------------------------------------------


write.csv(df, "WP_EXP_QualtricsData_Processed.csv", row.names = F)



# Import Puzzle Data ------------------------------------------------------


performance <- read.csv("wp_scores.csv") %>%
  rename(Condition_categorical = "Condition")

performance_long <- reshape2::melt(performance,
                              id.vars = c("Condition_categorical", "Group"),
                              variable.name = "Puzzle",
                              value.name = "Score")

performance_long <- performance_long %>% 
  mutate(ProblemStructure = ifelse(Puzzle == "Anagrams" | Puzzle == "Word.Production", "Well-Structured", "Ill-Structured"),
         SolutionSpace = ifelse(Puzzle == "Anagrams" | Puzzle == "Remote.Associates", "Constrained", "Unconstrained")) %>%
  select(c(1:3,5,6,4))
  

# Compute Performance Stats by Conditions ---------------------------------


perf_sample <- performance_long %>%
  group_by(Puzzle) %>%
  summarise_at(vars(Score), list(Min = min, Mean = mean, Max = max, Sd = sd)) %>%
  ungroup()

perf_groups <- performance_long %>%
  group_by(Condition_categorical, Puzzle) %>%
  summarise_at(vars(Score), list(Min = min, Mean = mean, Max = max, Sd = sd)) %>%
  ungroup()


perf_groupsXtypes <- performance_long %>%
  group_by(Condition_categorical, ProblemStructure, SolutionSpace) %>%
  summarise_at(vars(Score), list(Min = min, Mean = mean, Max = max, Sd = sd)) %>%
  ungroup()

# Two-Way ANOVA: Puzzle Type and Performance ------------------------------


####
# Plot Performance
####

# tell R where to save plots
setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp/plots")


# create box plots to visualize distributions

# creating more readable labels for facets
puzzle.labs <- c("Anagrams", "Remote Associates", "Word Production", "Alternative Uses")
names(puzzle.labs) <- c("Anagrams", "Remote.Associates", "Word.Production", "Alt.Uses" )

png(filename = "puzzle_performance_distribution.png",
    width = 2100, height = 2400,
    units = "px", res = 330)
ggplot(performance_long, 
       aes(y = Score, 
           x = Condition_categorical,
           fill = Condition_categorical)) + 
  geom_boxplot(color = "gray30") +
  facet_wrap(~Puzzle,
             labeller = labeller(Puzzle = puzzle.labs)) +
  theme_bw() +
  ylab("Performance Score") +
  xlab("") + 
  ggtitle("Puzzle Performance Distributions") +
  scale_fill_manual(values = c("goldenrod", "black")) +
  guides(fill = guide_legend("Condition")) + 
  theme(legend.position = "top",
        legend.text = element_text(size = 12),
        legend.direction = "horizontal",
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 12, color = "black"),
        axis.title.y = element_text(size = 12), 
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16)
        )
dev.off()



####
# Run Two-Way ANOVA: Does puzzle type predict performance?
####

# create the model
mod1 <- aov(Score ~ ProblemStructure * SolutionSpace, 
                data = performance_long)

# check residuals
res1 <- resid(mod1)
plot(density(res1))

# print model summary
summary(mod1) 

# post hoc analysis
TukeyHSD(mod1)

# get effect sizes
lsr::etaSquared(mod1)




