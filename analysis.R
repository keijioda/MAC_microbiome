
# MAC-Microbiome Study

# Setup -------------------------------------------------------------------

# Packages used
pacs <- c("tidyverse", "readxl", "haven", "tableone", "gtsummary", "gt", "ggbeeswarm", "tidytext")
sapply(pacs, require, character.only = TRUE)


# Read previous MAC data --------------------------------------------------

# Needed to extract treatment sequence
mac0 <- read_spss("./data/MAC Endpoint data with baseline values 102121.sav") %>% 
  janitor::clean_names()

# Check variable names
names(mac0)

# Variables needed
seq <- mac0 %>% 
  select(id, group, phase, visit, treatment, gender, age_b, weight_b)

# Group = 1: mac-control
# Group = 2: control-mac
print(seq)

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

cm_label <- c(
  "Glucose",
  "Insulin",
  "Total cholesterol",
  "Triglycerides",
  "HDL cholesterol",
  "LDL cholesterol",
  "VLDL cholesterol",
  "ApoA1",
  "ApoB",
  "CRP",
  "E-selectin"
)

cm_unit <- c(
 "mg/dL",
 "μIU/mg",
 "mg/dL",
 "mg/dL",
 "mg/dL",
 "mg/dL",
 "mg/dL",
 "mg/dL",
 "mg/dL",
 "mg/dL",
 "ng/dL"
)

# List of variables and their unit
bind_cols(var = cm_vars, label = cm_label, unit = cm_unit)

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

# Check if IDs are distinct
n_distinct(adip$id) == 35

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

# There are 45 species names begin with "Roseburia"
mb %>%
  filter(str_starts(Species, "Roseburia")) %>% 
  distinct(Species) %>% 
  pull()

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
    values_fn  = sum   # combines rows if >1 OTU/ASV shares the same Species label
  ) %>%
  arrange(id, visit) %>% 
  janitor::clean_names()


# Merge data --------------------------------------------------------------

# Group = 1: mac-control
# Group = 2: control-mac

df <- adip_long %>% 
  inner_join(cm, by = c("id", "visit")) %>% 
  left_join(seq_distinct, by = "id") %>% 
  inner_join(roseburia_long, by = c("id", "visit")) %>% 
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
    starts_with("roseburia")
  )

# Descriptive tables at baseline ------------------------------------------

# Variable labels
label_map <- c(
  "Age, years"               = "age_b",
  "Sex"                      = "gender",
  "Weight, kg"               = "weight_b",
  "BMI"                      = "bmi",
  "Body fat, %"              = "pct_fat",
  "Total cholesterol, mg/dL" = "chol",
  "LDL cholesterol, mg/dL"   = "ldl",
  "HDL cholesterol, mg/dL"   = "hdl",
  "ApoB, mg/dL"              = "apob"
)

# Filter for baseline, apply labels
df_labeled <- df %>% 
  filter(visit == 0) %>% 
  rename(!!!label_map)

# Produce a descriptive table by sequence
CreateTableOne(
  vars    = names(label_map),
  strata  = "group_lab",
  data    = df_labeled,
  addOverall = TRUE
) %>% 
  print(showAllLevels = TRUE)

# Using gtsummary
pval_4dp <- function(x) {
  ifelse(x < 0.0001, "<0.0001", sprintf("%.4f", x))
}

tbl <- df %>% 
  filter(visit == 0) %>% 
  select(group_lab, age_b, gender, weight_b, bmi, pct_fat, chol, ldl, hdl, apob) %>% 
  tbl_summary(
    by = group_lab,
    statistic = list(
      all_continuous()  ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = all_continuous() ~ 1,
    label  = list(
      age_b    ~ "Age (years)",
      gender   ~ "Sex",
      weight_b ~ "Weight (kg)",
      bmi      ~ "BMI (kg/m^2)",
      pct_fat  ~ "Body fat (%)",
      chol     ~ "Total cholesterol (mg/dL)",
      ldl      ~ "LDL cholesterol (mg/dL)",
      hdl      ~ "HDL cholesterol (mg/dL)",
      apob     ~ "ApoB (mg/dL)"
    )
  ) %>% 
  add_overall() %>% 
  add_p(
    test = list(
      all_continuous()  ~ "t.test",
      all_categorical() ~ "fisher.test"
    ),
    pvalue_fun = pval_4dp
  ) %>% 
  bold_labels() %>% 
  as_gt() %>% 
  tab_header(title = "Patient characteristics at baseline") %>% 
  opt_align_table_header(align = "left")

tbl

# Change score ------------------------------------------------------------

# Time-invariant covariates + baseline BMI/%fat, from the visit == 0 row
baseline_df <- df %>% 
  filter(visit == 0) %>% 
  select(id, group, group_lab, gender, age_b, weight_b, 
         bmi_b = bmi, pct_fat_b = pct_fat)

# Mac vs. Control values, reshaped wide and differenced
delta_df <- df %>% 
  filter(treatment %in% c("mac", "control")) %>% 
  select(id, treatment, chol, ldl, hdl, apob, roseburia_2) %>% 
  pivot_wider(
    id_cols     = id,
    names_from  = treatment,
    values_from = c(chol, ldl, hdl, apob, roseburia_2)
  ) %>% 
  mutate(
    delta_chol        = chol_mac        - chol_control,
    delta_ldl         = ldl_mac         - ldl_control,
    delta_hdl         = hdl_mac         - hdl_control,
    delta_apob        = apob_mac        - apob_control,
    delta_roseburia_2 = roseburia_2_mac - roseburia_2_control
  ) %>% 
  select(id, starts_with("delta_"))

# Combine into the final one-row-per-participant analytic dataset
df_delta <- baseline_df %>% 
  inner_join(delta_df, by = "id")


# Cardiometabolic variables -----------------------------------------------

# Histogram
df %>%
  filter(phase != 0) %>% 
  pivot_longer(cols = c("ldl", "chol", "hdl", "apob"), names_to = "var", values_to = "value") %>% 
  mutate(
    var = factor(var, 
    levels = c("chol", "ldl", "hdl", "apob"), 
    labels = c("Total cholesterol (mg/dL)", "LDL cholelsterol (mg/dL)", "HDL cholesterol (mg/dL)", "ApoB (mg/dL)")) 
  ) %>% 
  ggplot(aes(x = value)) +
  geom_histogram(aes(y = after_stat(density)), bins = 20) +
  geom_density(color = "cornflowerblue", linewidth = 1, adjust = 2) +
  labs(x = NULL, y = "Density") +
  facet_wrap(~ var, scales = "free") +
  theme_bw()


# Histogram on delta
df_delta %>%
  pivot_longer(
    cols = c("delta_chol", "delta_ldl", "delta_hdl", "delta_apob"), 
    names_to = "var", 
    values_to = "value"
  ) %>% 
  mutate(
    var = factor(var, 
                 levels = c("delta_chol", "delta_ldl", "delta_hdl", "delta_apob"), 
                 labels = c("Δ Total cholesterol", "Δ LDL", "Δ HDL", "Δ ApoB")) 
  ) %>% 
  ggplot(aes(x = value)) +
  geom_histogram(aes(y = after_stat(density)), bins = 20) +
  geom_density(color = "cornflowerblue", linewidth = 1, adjust = 2) +
  labs(x = NULL, y = "Density") +
  facet_wrap(~ var, scales = "free")

# Profile plot
df %>% 
  filter(visit != 0) %>%  
  mutate(phase = factor(phase)) %>% 
  pivot_longer(cols = c("ldl", "chol", "hdl", "apob"), names_to = "var", values_to = "value") %>% 
  mutate(
    var = factor(var, 
    levels = c("chol", "ldl", "hdl", "apob"), 
    labels = c("Total cholesterol (mg/dL)", "LDL cholelsterol (mg/dL)", "HDL cholesterol (mg/dL)", "ApoB (mg/dL)")) 
  ) %>% 
  ggplot(aes(x = phase, y = value, group = id, color = group_lab)) +
  geom_point() +
  geom_line() +
  scale_x_discrete(breaks = 1:2, expand = expansion(add = 0.1)) +
  labs(x = "Phase", y = NULL) +
  facet_grid(var ~ group_lab, scales = "free", switch = "y", axes = "all_x") +
  theme_bw() +
  theme(
    legend.position = "none",
    strip.placement = "outside",
    strip.background = element_blank()
  ) 

# Boxplot of deltas
df_delta %>%
  pivot_longer(
    cols = c("delta_ldl", "delta_chol", "delta_hdl", "delta_apob"), 
    names_to = "var", 
    values_to = "value"
  ) %>% 
  mutate(
    var = factor(var, 
    levels = c("delta_chol", "delta_ldl", "delta_hdl", "delta_apob"), 
    labels = c("Δ Total cholesterol", "Δ LDL", "Δ HDL", "Δ ApoB")) 
  ) %>% 
  ggplot(aes(x = var, y = value, color = var)) +
  geom_boxplot(outlier.shape = NA, width = 0.3) +
  geom_beeswarm(cex = 1.5) + 
  geom_hline(yintercept = 0, lty = 2) +
  labs(x = NULL, y = "Difference, mac - control") +
  theme(legend.position = "none")

# Barplot on delta
df_delta %>% 
  pivot_longer(
    cols = c(delta_chol, delta_ldl, delta_hdl, delta_apob), 
    names_to = "var", 
    values_to = "value"
  ) %>% 
  mutate(
    var = factor(var, 
                 levels = c("delta_chol", "delta_ldl", "delta_hdl", "delta_apob"),
                 labels = c("Δ Total cholesterol (mg/dL)", "Δ LDL (mg/dL)", 
                            "Δ HDL (mg/dL)", "Δ ApoB (mg/dL)")),
    id_ordered = reorder_within(id, value, var)
  ) %>% 
  ggplot(aes(x = id_ordered, y = value, fill = group_lab)) +
  geom_bar(stat = "identity") +
  scale_x_reordered() +
  facet_wrap(~ var, scales = "free") +
  labs(
    x = "Participant ID",
    y = "Difference: Macademia - Control", 
    fill = "Treatment sequence"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

# Descriptive statistics on delta
df_delta %>% 
  select(delta_chol, delta_ldl, delta_hdl, delta_apob) %>% 
  tbl_summary(
    statistic = list(
      all_continuous()  ~ "{mean} ({sd})"
    ),
    digits = all_continuous() ~ 1,
    label  = list(
      delta_chol ~ "Δ Total cholesterol (mac-control)",
      delta_ldl  ~ "Δ LDL cholesterol (mac-control)",
      delta_hdl  ~ "Δ HDL cholesterol (mac-control)",
      delta_apob ~ "Δ ApoB (mac-control)"
    )
  ) %>% 
  bold_labels() %>% 
  modify_header(label = "**Outcome**")

# Build mac/control/delta values in one wide frame
delta_full <- df %>% 
  filter(treatment %in% c("mac", "control")) %>% 
  select(id, treatment, chol, ldl, hdl, apob) %>% 
  pivot_wider(
    id_cols     = id,
    names_from  = treatment,
    values_from = c(chol, ldl, hdl, apob)
  ) %>% 
  mutate(
    chol_delta = chol_mac - chol_control,
    ldl_delta  = ldl_mac  - ldl_control,
    hdl_delta  = hdl_mac  - hdl_control,
    apob_delta = apob_mac - apob_control
  )

# Reshape to long (outcome x condition), summarize, then pivot back to wide
summary_tbl <- delta_full %>% 
  pivot_longer(
    cols         = -id,
    names_to     = c("outcome", "condition"),
    names_pattern = "(chol|ldl|hdl|apob)_(mac|control|delta)",
    values_to    = "value"
  ) %>% 
  group_by(outcome, condition) %>% 
  summarise(mean_sd = sprintf("%.1f (%.1f)", mean(value), sd(value)), .groups = "drop") %>% 
  pivot_wider(names_from = condition, values_from = mean_sd) %>% 
  mutate(
    outcome = factor(outcome, 
                     levels = c("chol", "ldl", "hdl", "apob"),
                     labels = c("Total cholesterol (mg/dL)", "LDL cholesterol (mg/dL)", 
                                "HDL cholesterol (mg/dL)", "ApoB (mg/dL)"))
  ) %>% 
  arrange(outcome) %>% 
  select(Outcome = outcome, Mac = mac, Control = control, `Δ (Mac-Control)` = delta)

summary_tbl %>% knitr::kable(align = c("l", "c", "c", "c"))


# Microbiome variables ----------------------------------------------------

# Histogram
df %>%
  filter(phase != 0) %>% 
  ggplot(aes(x = roseburia_2)) +
  geom_histogram(aes(y = after_stat(density)), bins = 20) +
  geom_density(color = "cornflowerblue", linewidth = 1, adjust = 2) +
  labs(x = NULL, y = "Density")

df %>%
  filter(phase != 0) %>% 
  ggplot(aes(x = roseburia_2)) +
  geom_histogram() +
  scale_x_continuous(transform = scales::pseudo_log_trans()) +
  labs(x = "Roseburia_2")

# Profile plot
df %>% 
  filter(phase != 0) %>%
  mutate(phase = factor(phase)) %>% 
  ggplot(aes(x = phase, y = roseburia_2, group = id, color = group_lab)) +
  geom_point() +
  geom_line() +
  scale_x_discrete(breaks = 1:2, expand = expansion(add = 0.1)) +
  scale_y_continuous(transform = scales::pseudo_log_trans()) +
  labs(x = "Phase", y = "Roseburia_2 (pseudo-log scale)") +
  facet_wrap(~ group_lab) +
  theme(legend.position = "bottom")

# Checking IDs with Roseburia_2 = 0
zero_check <- df %>% 
  filter(phase %in% c(1, 2)) %>% 
  select(id, phase, group_lab, roseburia_2) %>% 
  pivot_wider(names_from = phase, values_from = roseburia_2, names_prefix = "phase_")

# 11 IDs with both phases zero
zero_check %>% 
  filter(phase_1 == 0 & phase_2 == 0)

# 6 IDs with one phase zero
# When Roseburia_2 = 0, it is always in the control phase
zero_check %>% 
  filter(xor(phase_1 == 0, phase_2 == 0))

