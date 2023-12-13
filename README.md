# Minerva Project: Word Puzzles Experiment Data
 
 This repo contains R code files for data preparation and summarization associated with the word puzzles experiment conducted under the Minerva project.

 ## Qualtrics Survey Data

Qualtrics was used to adminster a set of measures of individual attributes in addition to percecptions of team process. 

### Psychological Collectivism

A 15-item measure of psychological collectivism developed and validated by Jackson and colleagues (2006) was used in the study. The measure captures five facets of of collectvism: preference, reliance, concern, norm acceptance, and goal priority  (3 items per facet). Collectivism was measured at two points in the study. The data labels include information about measurement time. For example, for the item "*I preferred to work in those groups rather than working alone.*", the data are labeled collectivism_t1_1 and collectivism_t2_1 to represent time 1 and time 2 measurements, respectively. 

According to Jackson et al. (2006):
* Perference and concern facets are relevant to cooperation as they "create a sense of attraction in the group"
* Goal priority and reliance facets are relevant to cooperation as they "facilitate the development of interdependence"
* Norm acceptance facet is relevant to cooperation, specifically prosocial behavior

*Scoring*

Responses are provided on a 5-point Likert-type scale ranging from strongly disagree to strongly agree, and can be assessed at the scale level (single variable) or facet level (five variables). 
Mean ratings, at the scale or facet level, are used to determine level of collectivism, where a higher value indicates greater collectivism. 

| Label  | Item  | Facet |
| :------------- | :------------- | :------------- |
| collectivism_1  | I preferred to work in those groups rather than working alone.  | preference  |
| collectivism_2  | Working in those groups was better than working alone.  | preference  |
| collectivism_3  | I wanted to work with those groups as opposed to working alone.  | preference  |
| collectivism_4  | I felt comfortable counting on group members to do their part.  | reliance  |
| collectivism_5  | I was not bothered by the need to rely on group members.  | reliance  |
| collectivism_6  | I felt comfortable trusting group members to handle their tasks.  | reliance  |
| collectivism_7  | The health of those groups was important to me.  | concern  |
| collectivism_8  | I cared about the well-being of those groups.  | concern  |
| collectivism_9  | was concerned about the needs of those groups.  | concern  | 
| collectivism_10  | I followed the norms of those groups.  | norm acceptance  | 
| collectivism_11  | I followed the procedures used by those groups.  | norm acceptance  | 
| collectivism_12  | I accepted the rules of those groups.  | norm acceptance  | 
| collectivism_13  | I cared more about the goals of those groups than my own goals.  | goal priority  | 
| collectivism_14  | I emphasized the goals of those groups more than my individual goals.  | goal priority  | 
| collectivism_15  | Group goals were more important to me than my personal goals.  | goal priority  | 


### Sociable and Aggressive Dominance

### Theory of Mind

### Stress

### Workload

### Personality

The Ten Item Personality Inventory (TIPI) developed by Gosling and colleagues (2003) was used in the study. The TIPI is used to measure the Big-Five personality dimensions: Extraversion, Agreeableness, Conscientiousness, Emotional Stability, Openness to Experiences.

*Scoring*

Responses are provided on a 7-point Likert-type scale ranging from strongly disagree to strongly agree. A subset of the items need to be reverse scored: 2, 4, 6, 8, and 10. Mean ratings of the two items for each personality scale are used to calculate scores (see table below).

Recode as follows:
* 7 = 1
* 6 = 2
* 5 = 3
* 4 = 4
* 3 = 5
* 2 = 6
* 1 = 7


| Label  | Item  | Scale |
| :------------- | :------------- | :------------- |
| TIPI_1 | Extraverted, enthusiastic | Extraversion |
| TIPI_2* | Critical, quarrelsome | Agreeableness |
| TIPI_3 | Dependable, self-disciplined | Conscientiousness |
| TIPI_4* | Anxious, easily upset | Emotional Stability |
| TIPI_5 | Open to new experiences, complex | Openness to Experiences |
| TIPI_6* | Reserved, quiet | Extraversion |
| TIPI_7 | Sympathetic, warm | Agreeableness |
| TIPI_8* | Disorganized, careless | Conscientiousness |
| TIPI_9 | Calm, emotionally stable | Emotional Stability |
| TIPI_10* |  Conventional, uncreative | Openness to Experiences |

Asterik denotes reverse-scored item.


Additional information is available at this [link](https://gosling.psy.utexas.edu/scales-weve-developed/ten-item-personality-measure-tipi/).



### Team Processes

 ## Joggle Cognition Battery Data

## References

Gosling, S. D., Rentfrow, P. J., & Swann, W. B., Jr. (2003). A Very Brief Measure of the Big Five Personality Domains. Journal of Research in Personality, 37, 504-528.

Jackson, C. L., Colquitt, J. A., Wesson, M. J., & Zapata-Phelan, C. P. (2006). Psychological collectivism: A measurement validation and linkage to group member performance. Journal of Applied Psychology, 91(4), 884.
