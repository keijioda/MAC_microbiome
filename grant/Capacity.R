
pacs <- c("tidyverse", "readxl")
sapply(pacs, require, character.only = TRUE)

# Read butyrate-propionate biosynthetic capacity scores
capacity <- read_excel('./data/SCFA_capacity_score_ZeeviD_2015.xlsx', sheet = 2) %>% 
  janitor::clean_names() %>% 
  filter(substr(sample_id, 1, 3) == "PNP")

# Check: Should be n = 900
stopifnot(nrow(capacity) == 900)

# Distribution of capacity score
capacity %>% 
  ggplot(aes(x = score_z)) +
  geom_histogram(bins = 40, color = "gray") +
  labs(x = "Frozon SCFA capacity score (z)", y = "Count")

# Summary statistics
summary(capacity$score_z)

# Pearson
# cor(capacity, age) = +0.043
# cor(capacity, BMI) = -0.042
capacity %>% 
  select(age_years, bmi, score_z) %>% 
  cor(use = "pairwise") %>% 
  round(3)

# Spearman
# cor(capacity, age) = +0.043
# cor(capacity, BMI) = -0.056
capacity %>% 
  select(age_years, bmi, score_z) %>% 
  cor(use = "pairwise", method = "spearman") %>% 
  round(3)

