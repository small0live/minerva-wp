
## Performance Analysis
## Word Puzzle Experiment
## Minerva Project


# Load Packages -----------------------------------------------------------


library(tidyverse)


# Import Data -------------------------------------------------------------

## set working directory (tell R where the data is)
setwd("~/Documents/CSL/Minerva/Word_Puzzles_Experiment/minerva-wp/data")

## import csv file as data frame
perform <- read.csv("WP_Performance.csv") %>%
  select(-contains(c("Tot", "session")))



# Prep for Viz + Analysis -------------------------------------------------

## convert to long format
perform <- reshape2::melt(perform,
                          id.vars = c("GroupID","Condition_categorical"),
                          value.name = "Score")

## create viz friendly labels
perform <- perform %>%
  mutate(Puzzle = ifelse(grepl("ANA", perform$variable), "Anagrams", 
                         ifelse(grepl("RAT", perform$variable), "Remote Associates", 
                                ifelse(grepl("WP", perform$variable), "Word Production", "Alternative Uses"))),
         ProblemStructure = ifelse(Puzzle == "Anagrams" | Puzzle == "Word Production",
                                   "WellStructured", "IllStructured"),
         SolutionSpace = ifelse(Puzzle == "Anagrams" | Puzzle == "Remote Associates",
                                "Constrained", "Unconstrained"))

## convert variables to factor type
perform$Puzzle <- factor(perform$Puzzle,
                    levels = c("Anagrams",
                               "Remote Associates",
                               "Word Production",
                               "Alternative Uses"))

perform$Condition_categorical <- factor(perform$Condition_categorical)
perform$ProblemStructure <- factor(perform$ProblemStructure)
perform$SolutionSpace <- factor(perform$SolutionSpace)


# Visualize Data ----------------------------------------------------------

####
## viz for both conditions
####

## create box plot: condition distributions
ggplot(perform,
       aes(x = Condition_categorical, fill = Condition_categorical, y = Score)) +
  geom_boxplot(color = "gray20") +
  facet_wrap(~Puzzle) +
  ggtitle("Distribution of Puzzle Scores by Group Condition") +
  scale_fill_manual(values = c("#920000", "#b6dbff")) +
  theme_bw() +
  theme(legend.position = "top",
        legend.direction = "horizontal",
        legend.text = element_text(size = 12),
        strip.text.x = element_text(size = 12),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 12),
        axis.title.x = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18))


## create bar plot: condition means
ggplot(perform,
       aes(x = Puzzle,  fill = Puzzle,
           y = Score)) +
  geom_bar(position = "dodge", stat = "summary", fun = "mean",
           colour = "black", linewidth = 0.2) +
  facet_wrap(~Condition_categorical) +
  ggtitle("Mean Puzzle Score by Group Condition") +
  xlab("") +
  ylab("Mean Score") +
  coord_cartesian(ylim = c(0, 1)) +
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


####
## viz for real group condition only
####

## keep only real group data
rg_only <- perform %>% subset(Condition_categorical == "Real Group")

## getting RG ID for sorted plot later
rg_only <- rg_only %>% 
  mutate(sort_id = sub("^\\D+(\\d)", "\\1", rg_only$GroupID))

rg_only$sort_id <- as.numeric(rg_only$sort_id)

## create bar plot: group means
ggplot(rg_only,
       aes(x = Puzzle,  fill = Puzzle,
           y = Score)) +
  geom_bar(position = "dodge", stat = "identity",
           colour = "black", linewidth = 0.2) +
  facet_wrap(~sort_id,
             nrow = 3) +
  ggtitle("Puzzle Scores for Real Groups") +
  xlab("") +
  ylab("Mean Score") +
  coord_cartesian(ylim = c(0, 1)) +
  scale_fill_manual(values = c("#004949", "#490092", "#db6d00", "#ffff6d")) +
  theme_bw() +
  theme(legend.position = "top",
        legend.direction = "horizontal",
        legend.text = element_text(size = 12),
        strip.text.x = element_text(size = 12),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 12),
        axis.text.x = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
        panel.grid.major.x = element_blank())



# Get Descriptive Stats ---------------------------------------------------

## using functions from rstatix package here + onward (as indicated by rstatix::)

## mean and sd
perform %>%
  group_by(Condition_categorical, Puzzle) %>%
  rstatix::get_summary_stats(Score, type = "mean_sd")


perform %>%
  group_by(Condition_categorical, ProblemStructure) %>%
  rstatix::get_summary_stats(Score, type = "mean_sd")

perform %>%
  group_by(Condition_categorical, SolutionSpace) %>%
  rstatix::get_summary_stats(Score, type = "mean_sd")


# Check Stat Assumptions --------------------------------------------------

## check outliers
perform %>%
  group_by(Condition_categorical, ProblemStructure, SolutionSpace) %>%
  rstatix::identify_outliers(Score)

## check normality
perform %>%
  group_by(Condition_categorical, ProblemStructure, SolutionSpace) %>%
  rstatix::shapiro_test(Score)

## check normality (visually)
ggpubr::ggqqplot(perform, "Score", ggtheme = theme_bw()) +
  facet_grid(Puzzle ~ Condition_categorical, labeller = "label_both")

## check homogeneity of variances
perform %>%
  group_by(ProblemStructure, SolutionSpace) %>%
  rstatix::levene_test(Score ~ Condition_categorical)


# Run RM Mixed ANOVA ------------------------------------------------------

## create model
res.aov <- rstatix::anova_test(
  data = perform, dv = Score, wid = GroupID, between = Condition_categorical,
  within = c(ProblemStructure, SolutionSpace)
  )

## print ANOVA table
rstatix::get_anova_table(res.aov)


# Post Hoc Analysis -------------------------------------------------------

## effect of group at each time point
one.way <- perform %>%
  group_by(ProblemStructure) %>%
  rstatix::anova_test(dv = Score, wid = GroupID, between = Condition_categorical) %>%
  rstatix::get_anova_table() %>%
  rstatix::adjust_pvalue(method = "bonferroni")

one.way

one.way <- perform %>%
  group_by(SolutionSpace) %>%
  rstatix::anova_test(dv = Score, wid = GroupID, between = Condition_categorical) %>%
  rstatix::get_anova_table() %>%
  rstatix::adjust_pvalue(method = "bonferroni")

one.way

## pairwise comparisons
pwc <- perform %>%
  group_by(ProblemStructure) %>%
  rstatix::pairwise_t_test(Score ~ Condition_categorical, p.adjust.method = "bonferroni")

pwc

pwc <- perform %>%
  group_by(SolutionSpace) %>%
  rstatix::pairwise_t_test(Score ~ Condition_categorical, p.adjust.method = "bonferroni")

pwc

