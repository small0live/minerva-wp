# Analysis 

Analysis is conducted in R. The scripts in this folder can be applied to data from the Word Puzzles Experiment.

## Nominal Groups

Participants in the nominal group condition were randomly selected to form 3-person groups. 

## Task Performance

The experimental task consisted of four types of word puzzles which varied in terms of problem structure and solution space: anagrams, remote associates, word production, and unusual uses. 

|  | Well-Structured  | Ill-Structured  |
| :-------------  | :------------- | :------------- |
| **Constrained** | Angrams  | Remote Associates  |
| **Unconstrained** | Word Production  | Unusual Uses  |

### Data

Performance data are stored in Google Drive:

Minerva > Experiments > 1.1 Word Puzzles Experiment > Data Analysis > Word Puzzle Scoring.

The Group_Scores_Clean sheet in the above mentioned file can be used with R script described below.

### Scoring

* Anagrams: proportion correct
* Remote Associates: proportion correct
* Word Production: proportion generated (max = 30)
* Uses: proportion generated (max = 52)

Note: Any correct answers across all members of a nominal group are treated as a correct answer by the group.

### R Script

A script for preparing, visualzing, and analyzing performance data is provided: just_performance.R. Data downloaded using the above instruction can be used with this script.

Before running the script, ensure that the working directory and file name specified align with your local settings.


## Task Difficulty

