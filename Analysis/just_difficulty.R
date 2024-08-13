

## Difficulty Ratings Analysis
## Word Puzzle Experiment
## Minerva Project


# Load Packages -----------------------------------------------------------


library(tidyverse) # a suite of packages including dplyr and ggplot2, see https://www.tidyverse.org/ 


# Prep Difficulty Ratings Data --------------------------------------------


## tell R where the data is
setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp/data")

## import diff data as data frame
df <- read.csv("WP_DifficultyRatings.csv") %>%
  rename(pid = "Participant")


# Prep for Viz + Analysis -------------------------------------------------


## convert to long format
df <- reshape2::melt(df, 
           id.vars = "pid",
           value.name = "Rating")

## create viz friendly labels
df <- df %>%
  mutate(Puzzle = ifelse(grepl("Ana", df$variable), "Anagrams", 
                         ifelse(grepl("Remote", df$variable), "Remote Associates", 
                                ifelse(grepl("WordProd", df$variable), "Word Production", "Alternative Uses"))))


# Import Qualtrics Data ---------------------------------------------------


## import data 
qualtrics <- read.csv("WP_Qualtrics.csv") %>%
  slice(-c(1, 2)) %>% # remove extra header rows
  select(contains(c(
                    "session",
                    "condition",
                    "pid",
                    "wp_order"
                    ))) %>% 
  mutate(Condition_categorical = ifelse(Condition == 1, "Nominal Group", "Real Group"), 
         wp_order = ifelse(wp_order == "", NA, paste0(wp_order))) %>% # replace empty cells with NA in word puzzle order column 
  group_by(session) %>%
  fill(wp_order, .direction = 'updown') %>% # fill in missing puzzle order info for some RG participants
  ungroup()

## remove trailing white space from human entries
qualtrics$pid <- trimws(qualtrics$pid)


# Import RG/NG Assignment Data ---------------------------------------------


## nominal group pids
ng_pids <- read.csv("Nominal_Group_PIDS.csv") %>%
  rename(GroupID = "NG_Assignment",
         pid = "PID")

## real group pids
rg_sids <- read.csv("WP_Performance.csv") %>%
  subset(Condition_categorical == "Real Group", select = c(GroupID, session))


# Merge Data Sets ---------------------------------------------------------

## merge difficulty and qualtrics data
df <- merge(df, qualtrics,
            by = "pid",
            all.x = T)
  
## remove excluded data points
df <- df %>% 
  subset(session != 7 & session != 38 & pid != "M44" & pid != "M45")

## subset nominal group and real group for clean merging
ng <- df %>% subset(Condition_categorical == "Nominal Group")

rg <- df %>% subset(Condition_categorical == "Real Group")

ng <- merge(ng, ng_pids,
            by = "pid")

rg <- merge(rg, rg_sids,
            by = "session")

df <- rbind(rg, ng)


## remove data frames we don't need any more
rm(rg, ng, rg_sids, ng_pids, qualtrics)

## sloppy reordering
df <- df %>% select(c(2,1,9,6,8,7,3,5,4))

## save the data
#write.csv(df,
#          "WP_DifficultyRatings_Labeled.csv",
#          row.names = F)

# Get Sample Counts -------------------------------------------------------


df %>%
  group_by(pid) %>%
  filter(row_number()==1) %>%
  ungroup() %>%
  group_by(Condition_categorical) %>%
  tally()


# Prep for Viz + Analysis -------------------------------------------------

## create viz friendly labels
df <- df %>%
  mutate(ProblemStructure = ifelse(Puzzle == "Anagrams" | Puzzle == "Word Production",
                                   "WellStructured", "IllStructured"),
         SolutionSpace = ifelse(Puzzle == "Anagrams" | Puzzle == "Remote Associates",
                                "Constrained", "Unconstrained"))

## convert variables to factor type
df$Puzzle <- factor(df$Puzzle,
                    levels = c("Anagrams",
                               "Remote Associates",
                               "Word Production",
                               "Alternative Uses"))

df$Condition_categorical <- factor(df$Condition_categorical)
df$ProblemStructure <- factor(df$ProblemStructure)
df$SolutionSpace <- factor(df$SolutionSpace)


# Visualize ---------------------------------------------------------------

####
## viz for both conditions
####

## create bar plot: sample means
ggplot(df,
       aes(x = Puzzle,  fill = Puzzle,
           y = Rating)) +
  geom_bar(position = "dodge", stat = "summary", fun = "mean",
           colour = "black", linewidth = 0.2) +
  ggtitle("Sample Mean Difficulty Ratings") +
  xlab("") +
  ylab("Mean Rating") +
  coord_cartesian(ylim = c(1, 7)) +
  scale_y_continuous(breaks = c(1,2,3,4,5,6,7)) +
  scale_fill_manual(values = c("#004949", "#490092", "#db6d00", "#ffff6d")) +
  theme_bw() +
  theme(legend.position = "top",
        legend.direction = "horizontal",
        legend.text = element_text(size = 12),
        axis.ticks.x = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18))


## fill in some missing data
df <- df %>%
  mutate(Condition_categorical = ifelse(is.na(Condition_categorical), 
                                        "Nominal Group", 
                                        paste(Condition_categorical)))

## create bar plot: condition means
ggplot(df,
       aes(x = Puzzle,  fill = Puzzle,
           y = Rating)) +
  geom_bar(position = "dodge", stat = "summary", fun = "mean",
           colour = "black", linewidth = 0.2) +
  facet_wrap(~Condition_categorical) +
  ggtitle("Mean Difficulty Ratings by Group Condition") +
  xlab("") +
  ylab("Mean Rating") +
  coord_cartesian(ylim = c(1, 7)) +
  scale_y_continuous(breaks = c(1,2,3,4,5,6,7)) +
  scale_fill_manual(values = c("#004949", "#490092", "#db6d00", "#ffff6d")) +
  theme_bw() +
  theme(legend.position = "top",
        legend.direction = "horizontal",
        legend.text = element_text(size = 12),
        strip.text.x = element_text(size = 12),
        axis.ticks.x = element_blank(),
        axis.text = element_text(size = 12),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
        panel.grid.major.x = element_blank())



## create box plot: condition distributions
ggplot(df,
       aes(x = Condition_categorical, fill = Condition_categorical, y = Rating)) +
  geom_boxplot(color = "gray20") +
  facet_wrap(~Puzzle) +
  ggtitle("Distribution of Difficulty Ratings by Group Condition") +
  scale_fill_manual(values = c("#920000", "#b6dbff")) +
  coord_cartesian(ylim = c(1, 7)) +
  scale_y_continuous(breaks = c(1,2,3,4,5,6,7)) +
  theme_bw() +
  theme(legend.position = "top",
        legend.direction = "horizontal",
        legend.text = element_text(size = 12),
        strip.text.x = element_text(size = 12),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 12),
        axis.title.x = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
        panel.grid.major.x = element_blank())


# Get Descriptive Stats ---------------------------------------------------


## using functions from rstatix package here + onward (as indicated by rstatix::)

df %>%
  group_by(Condition_categorical, ProblemStructure, SolutionSpace) %>%
  rstatix::get_summary_stats(Rating, type = "mean_sd")

df %>%
  group_by(Condition_categorical, ProblemStructure) %>%
  rstatix::get_summary_stats(Rating, type = "mean_sd")

df %>%
  group_by(Condition_categorical, SolutionSpace) %>%
  rstatix::get_summary_stats(Rating, type = "mean_sd")


# Check Stat Assumptions --------------------------------------------------


## check outliers
df %>%
  group_by(Condition_categorical, ProblemStructure, SolutionSpace) %>%
  rstatix::identify_outliers(Rating)

## check normality
df %>%
  group_by(Condition_categorical, ProblemStructure, SolutionSpace) %>%
  rstatix::shapiro_test(Rating)

## check normality (visually)
ggpubr::ggqqplot(df, "Rating", ggtheme = theme_bw()) +
  facet_grid(Puzzle ~ Condition_categorical, labeller = "label_both")

## check homogeneity of variances
df %>%
  group_by(ProblemStructure, SolutionSpace) %>%
  rstatix::levene_test(Rating ~ Condition_categorical)

# Run RM Mixed ANOVA ------------------------------------------------------

## create model
res.aov <- rstatix::anova_test(
  data = df, dv = Rating, wid = pid, between = Condition_categorical,
  within = c(ProblemStructure, SolutionSpace)
  )

## print ANOVA table
rstatix::get_anova_table(res.aov)


# Post Hoc Analysis -------------------------------------------------------

## effect of group at each time point
one.way <- df %>%
  group_by(ProblemStructure) %>%
  rstatix::anova_test(dv = Rating, wid = pid, between = Condition_categorical) %>%
  rstatix::get_anova_table() %>%
  rstatix::adjust_pvalue(method = "bonferroni")

one.way

one.way <- df %>%
  group_by(SolutionSpace) %>%
  rstatix::anova_test(dv = Rating, wid = pid, between = Condition_categorical) %>%
  rstatix::get_anova_table() %>%
  rstatix::adjust_pvalue(method = "bonferroni")

one.way

## pairwise comparisons
pwc <- df %>%
  group_by(ProblemStructure) %>%
  rstatix::pairwise_t_test(Rating ~ Condition_categorical, p.adjust.method = "bonferroni")

pwc

pwc <- df %>%
  group_by(SolutionSpace) %>%
  rstatix::pairwise_t_test(Rating ~ Condition_categorical, p.adjust.method = "bonferroni")

pwc



