
# For grant proposal

# Setup -------------------------------------------------------------------

# Packages used
pacs <- c(
  "tidyverse",
  "readxl", 
  "haven",
  "irr"
)

sapply(pacs, require, character.only = TRUE)


# Read previous MAC data --------------------------------------------------

# Needed to extract treatment sequence
mac0 <- read_spss("./data/MAC Endpoint data with baseline values 102121.sav") %>% 
  janitor::clean_names()

# Variables needed
seq <- mac0 %>% 
  select(id, group, phase, visit, treatment, gender, age_b, weight_b)

# Distinct data with ID, Group, gender, age, weight
# n = 35
seq_distinct <- seq %>% 
  select(id, group, gender, age_b, weight_b) %>% 
  distinct()


# Read cardiometabolic data -----------------------------------------------

# Variable list
cm_vars <- c(
  "glucose",
  "insulin",
  "chol",
  "trigs",
  "hdl",
  "ldl",
  "vldl",
  "apoa1",
  "apob",
  "crp",
  "eselectin"
)

# 108 obs x 15 variables
cm <- read_excel("./data/LLU_MAC Study_cardiometabolic outcomes.xlsx", sheet = "Data copy") %>% 
  setNames(c("id", "phase", "visit", "clinic_date", cm_vars)) %>%  
  mutate(clinic_date = as.Date(clinic_date))

# Check distinct IDs: 38 participants
n_distinct(cm$id)


# Read anthropometric data ------------------------------------------------

# Needed for adiposity variables
# 35 subj x 23 vars
adip <- read_excel("./data/MAC Anthropometric data.xlsx") %>% 
  janitor::clean_names() %>% 
  rename(id = study_id)

# Make it to long format
# Should have 35 * 3 = 105 obs
adip_long <- adip %>% 
  select(
    id, 
    visit_0_in_body_bmi, 
    clinic_4_in_body_bmi,
    clinic_9_wk_18_in_body_bmi,
    visit_0_in_body_percent_body_fat,
    clinic_4_in_body_percent_body_fat,
    clinic_9_wk_18_in_body_percent_body_fat
  ) %>%
  rename(
    bmi_0     = visit_0_in_body_bmi,
    bmi_4     = clinic_4_in_body_bmi,
    bmi_9     = clinic_9_wk_18_in_body_bmi,
    pct_fat_0 = visit_0_in_body_percent_body_fat,
    pct_fat_4 = clinic_4_in_body_percent_body_fat,
    pct_fat_9 = clinic_9_wk_18_in_body_percent_body_fat
  ) %>%
  pivot_longer(
    cols = -id,
    names_to = c(".value", "visit"),
    names_pattern = "(bmi|pct_fat)_(\\d+)"
  ) %>%
  mutate(visit = as.numeric(visit)) %>%
  arrange(id, visit)


# Read microbiome data ----------------------------------------------------

# 4166 rows x 112 columns
mb <- read_excel("./data/human_mac_study_abundance_data.xls")  

# Select "Roseburia" and make it to long format
# Results in 105 obs x 47 vars
roseburia_long <- mb %>%
  filter(str_starts(Species, "Roseburia")) %>%
  select(Species, starts_with("MAC")) %>%
  pivot_longer(
    cols = -Species,
    names_to = "sample",
    values_to = "abundance"
  ) %>%
  mutate(
    id    = as.integer(str_extract(sample, "(?<=MAC)\\d+")),
    visit = as.integer(str_extract(sample, "(?<=v)\\d+"))
  ) %>%
  select(-sample) %>%
  pivot_wider(
    id_cols    = c(id, visit),
    names_from = Species,
    values_from = abundance,
    values_fn  = sum 
  ) %>%
  arrange(id, visit) %>% 
  janitor::clean_names()


# Read Shannon index data -------------------------------------------------

# 105 rows x 12 columns
shannon <- read_csv("./data/metadata_with_alpha_div_indices.csv") %>% 
  janitor::clean_names() %>% 
  mutate(
    id    = parse_number(participant_id),
    visit = parse_number(visit)
  ) %>% 
  select(id, visit, shannon)

# Merge data --------------------------------------------------------------

# Group = 1: mac-control
# Group = 2: control-mac

df <- adip_long %>% 
  inner_join(cm,             by = c("id", "visit")) %>% 
  left_join(seq_distinct,    by = c("id"))          %>% 
  inner_join(roseburia_long, by = c("id", "visit")) %>% 
  inner_join(shannon,        by = c("id", "visit")) %>% 
  mutate(
    group_lab = factor(group, labels = c("mac-control", "control-mac")),
    phase     = ifelse(visit == 0, 0, phase),
    treatment = case_when(
      visit == 0                                            ~ "baseline",
      (group == 1 & phase == 1) | (group == 2 & phase == 2) ~ "mac",
      (group == 1 & phase == 2) | (group == 2 & phase == 1) ~ "control"
    )
  ) %>% 
  select(
    id, 
    group, 
    group_lab, 
    clinic_date, 
    visit, 
    phase, 
    treatment,
    gender,
    age_b,
    weight_b,
    bmi, 
    pct_fat,
    chol,
    ldl, 
    hdl,
    apob,
    shannon,
    starts_with("roseburia")
  )


# ICC ---------------------------------------------------------------------

# ICC(2, 1) for absolute agreement
# Use only control-first group
# Compare at baseline and at the end of control phase
df_icc <- df %>% 
  select(id, group, group_lab, visit, phase, shannon) %>% 
  filter(group == 2, phase %in% c(0, 1))

# Make it to wide format
df_icc_wide <- df_icc %>% 
  select(id, phase, shannon) %>% 
  pivot_wider(names_from = phase, values_from = shannon, names_prefix = "phase_")

# Check
df_icc_wide

# Two-way, single-measure ICC for absolute agreement
df_icc_wide %>% 
  select(-id) %>% 
  icc(model="twoway", type="agreement")
