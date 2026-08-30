
# MAC-Microbiome Study

# Setup -------------------------------------------------------------------

# Packages used
pacs <- c(
  "tidyverse",
  "readxl", 
  "haven", 
  "tableone", 
  "gtsummary",
  "gt", 
  "ggbeeswarm", 
  "tidytext",
  "emmeans",
  "kableExtra",
  "lme4",
  "lmerTest",
  "influence.ME",
  "broom.mixed"
)

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

adip %>% select(visit_0_in_body_percent_body_fat) %>% 
  pull(visit_0_in_body_percent_body_fat) %>% summary()

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


# Read Shannon index data -------------------------------------------------

# 105 rows x 12 columns
shannon <- read_csv("./data/metadata_with_alpha_div_indices.csv") %>% 
  janitor::clean_names() %>% 
  mutate(
    id    = parse_number(participant_id),
    visit = parse_number(visit)
  ) %>% 
  select(id, visit, shannon)

shannon

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
  select(id, treatment, chol, ldl, hdl, apob, shannon, roseburia_2) %>% 
  pivot_wider(
    id_cols     = id,
    names_from  = treatment,
    values_from = c(chol, ldl, hdl, apob, shannon, roseburia_2)
  ) %>% 
  mutate(
    delta_chol        = chol_mac        - chol_control,
    delta_ldl         = ldl_mac         - ldl_control,
    delta_hdl         = hdl_mac         - hdl_control,
    delta_apob        = apob_mac        - apob_control,
    delta_shannon     = shannon_mac     - shannon_control,
    delta_roseburia_2 = roseburia_2_mac - roseburia_2_control
  ) %>% 
  select(id, starts_with("delta_"))

# Combine into the final one-row-per-participant analytic dataset
df_delta <- baseline_df %>% 
  inner_join(delta_df, by = "id")

df_delta %>% 
  ggplot(aes(x = delta_roseburia_2, y = delta_shannon)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

# Correlation b/w Δ Roseburia_2 and Δ Shannon index
# Very weak negative correlation: r = -0.035
df_delta %>% 
  select(delta_roseburia_2, delta_shannon) %>% 
  cor()

cor.test(df_delta$delta_shannon, df_delta$delta_roseburia_2)

# Cardiometabolic variables -----------------------------------------------

# Histogram
df %>%
  filter(phase != 0) %>% 
  pivot_longer(cols = c("ldl", "chol", "hdl", "apob"), names_to = "var", values_to = "value") %>% 
  mutate(
    var = factor(var, 
    levels = c("chol", "ldl", "hdl", "apob"), 
    labels = c("Total cholesterol (mg/dL)", "LDL cholesterol (mg/dL)", "HDL cholesterol (mg/dL)", "ApoB (mg/dL)")) 
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
    labels = c("Total cholesterol (mg/dL)", "LDL cholesterol (mg/dL)", "HDL cholesterol (mg/dL)", "ApoB (mg/dL)")) 
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
  theme_bw() +
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
  select(id, treatment, chol, ldl, hdl, apob, shannon, roseburia_2) %>% 
  pivot_wider(
    id_cols     = id,
    names_from  = treatment,
    values_from = c(chol, ldl, hdl, apob, shannon, roseburia_2)
  ) %>% 
  mutate(
    chol_delta        = chol_mac - chol_control,
    ldl_delta         = ldl_mac  - ldl_control,
    hdl_delta         = hdl_mac  - hdl_control,
    apob_delta        = apob_mac - apob_control,
    shannon_delta     = shannon_mac - shannon_control,
    roseburia_2_delta = roseburia_2_mac - roseburia_2_control
  )

# Reshape to long (outcome x condition), summarize, then pivot back to wide
summary_tbl <- delta_full %>% 
  pivot_longer(
    cols          = matches("^(chol|ldl|hdl|apob)_(mac|control|delta)$"),
    names_to      = c("outcome", "condition"),
    names_pattern = "(chol|ldl|hdl|apob)_(mac|control|delta)",
    values_to     = "value"
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



# Shannon index -----------------------------------------------------------

# Histogram, Shannon index
df %>%
  filter(phase != 0) %>% 
  ggplot(aes(x = shannon)) +
  geom_histogram() +
  labs(x = "Shannon index") +
  theme_bw()

# Profile plot, Shannon index 
df %>% 
  filter(phase != 0) %>%
  mutate(phase = factor(phase)) %>% 
  ggplot(aes(x = phase, y = shannon, group = id, color = group_lab)) +
  geom_point() +
  geom_line() +
  scale_x_discrete(breaks = 1:2, expand = expansion(add = 0.1)) +
  labs(x = "Phase", y = "Shannon index") +
  facet_wrap(~ group_lab) +
  theme_bw() +
  theme(legend.position = "bottom")

# Descriptive stats, Mean and SD
delta_full %>% 
  select(id, shannon_mac, shannon_control, shannon_delta) %>% 
  rename(mac = shannon_mac, control = shannon_control, delta = shannon_delta) %>% 
  pivot_longer(-id, names_to = "treatment", values_to = "value") %>% 
  mutate(treatment = factor(treatment, levels = c("mac", "control", "delta"))) %>% 
  group_by(treatment) %>% 
  summarise(mean_sd = sprintf("%.2f (%.2f)", mean(value), sd(value)), .groups = "drop") %>% 
  pivot_wider(names_from = "treatment", values_from = mean_sd) %>%
  rename(Mac = mac, Control = control, `Δ (Mac-Control)` = delta) %>%
  mutate(Variable = "Shannon") %>% 
  select(Variable, everything())

# Histogram on Shannon delta
df_delta %>% 
  ggplot(aes(x = delta_shannon)) +
  geom_histogram()

# Scatterplot of deltas
df_delta %>% 
  select(id, group, pct_fat_b, starts_with("delta_")) %>% 
  mutate(
    pct_fat_b_cat = ifelse(pct_fat_b < 43, 0, 1),
    pct_fat_b_cat = factor(pct_fat_b_cat, labels = c("<43%", "≥43%"))
  ) %>% 
  pivot_longer(
    cols = c(delta_chol, delta_ldl, delta_hdl, delta_apob),
    names_to = "var",
    values_to = "value"
  ) %>% 
  mutate(
    var = factor(var, 
                 levels = c("delta_chol", "delta_ldl", "delta_hdl", "delta_apob"),
                 labels = c("Total cholesterol", "LDL", "HDL", "ApoB"))
  ) %>% 
  ggplot(aes(x = delta_shannon, y = value, color = pct_fat_b_cat)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  # scale_x_continuous(transform = scales::pseudo_log_trans(sigma = 1)) +
  facet_wrap(~ var, scales = "free_y") +
  labs(
    x = "Δ Shannon (Mac − Control)", 
    y = "Δ outcome (Mac − Control)",
    color = "% fat at baselinie"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

# Scatterplot of cardiometabolic vs Shannon index
df %>% 
  filter(visit != 0) %>% 
  select(id, treatment, shannon, chol, ldl, hdl, apob) %>% 
  pivot_longer(
    cols = c(chol, ldl, hdl, apob),
    names_to = "var",
    values_to = "value"
  ) %>% 
  mutate(
    var = factor(var, 
                 levels = c("chol", "ldl", "hdl", "apob"),
                 labels = c("Total cholesterol", "LDL cholesterol", "HDL cholesterol", "ApoB"))) %>% 
  ggplot(aes(x = shannon, y = value)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(aes(color = treatment)) +
  facet_wrap(~var, scale = "free_y") +
  labs(
    x     = "Shannon index", 
    y     = "Cardiometabolic measures (mg/dL)",
    color = "Treatment"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

# Roseburia_2 -------------------------------------------------------------

# Histogram, Roseburia_2
df %>%
  filter(phase != 0) %>% 
  ggplot(aes(x = roseburia_2)) +
  geom_histogram(aes(y = after_stat(density)), bins = 20) +
  geom_density(color = "cornflowerblue", linewidth = 1, adjust = 2) +
  labs(x = NULL, y = "Density")

# Histogram, Roseburia_2, log scale
df %>%
  filter(phase != 0) %>% 
  ggplot(aes(x = roseburia_2)) +
  geom_histogram() +
  scale_x_continuous(transform = scales::pseudo_log_trans()) +
  labs(x = "Roseburia_2")

# Profile plot, Roseburia_2
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
  theme_bw() +
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

# Descriptive stats, Median and IQR
delta_full %>% 
  select(id, roseburia_2_mac, roseburia_2_control, roseburia_2_delta) %>%
  rename(mac = roseburia_2_mac,  control = roseburia_2_control) %>% 
  pivot_longer(-id, names_to = "treatment", values_to = "value") %>% 
  mutate(treatment = factor(treatment, levels = c("mac", "control", "roseburia_2_delta"))) %>% 
  group_by(treatment) %>% 
  summarise(median_iqr = sprintf("%.1f (%.1f)", median(value), IQR(value)), .groups = "drop") %>% 
  pivot_wider(names_from = "treatment", values_from = median_iqr) %>% 
  rename(Mac = mac, Control = control, `Δ (Mac-Control)` = roseburia_2_delta) %>% 
  mutate(Variable = "Roseburia_2") %>% 
  select(Variable, everything())

# Histogram on roseburia_2 delta
df_delta %>% 
  ggplot(aes(x = delta_roseburia_2)) +
  geom_histogram()

# Scatterplot of deltas
df_delta %>% 
  select(id, group, pct_fat_b, starts_with("delta_")) %>% 
  mutate(
    pct_fat_b_cat = ifelse(pct_fat_b < 43, 0, 1),
    pct_fat_b_cat = factor(pct_fat_b_cat, labels = c("<43%", "≥43%"))
  ) %>% 
  pivot_longer(
    cols = c(delta_chol, delta_ldl, delta_hdl, delta_apob),
    names_to = "var",
    values_to = "value"
  ) %>% 
  mutate(
    var = factor(var, 
                 levels = c("delta_chol", "delta_ldl", "delta_hdl", "delta_apob"),
                 labels = c("Total cholesterol", "LDL", "HDL", "ApoB"))
  ) %>% 
  ggplot(aes(x = delta_roseburia_2, y = value, color = pct_fat_b_cat)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  # scale_x_continuous(transform = scales::pseudo_log_trans(sigma = 1)) +
  facet_wrap(~ var, scales = "free_y") +
  labs(
    x = "Δ Roseburia_2 (Mac − Control)", 
    y = "Δ outcome (Mac − Control)",
    color = "% fat at baselinie"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

# Scatterplot of cardiometabolic vs Roseburia_2
df %>% 
  filter(visit != 0) %>% 
  select(id, treatment, roseburia_2, chol, ldl, hdl, apob) %>% 
  pivot_longer(
    cols = c(chol, ldl, hdl, apob),
    names_to = "var",
    values_to = "value"
  ) %>% 
  mutate(
    var = factor(var, 
                 levels = c("chol", "ldl", "hdl", "apob"),
                 labels = c("Total cholesterol", "LDL cholesterol", "HDL cholesterol", "ApoB"))) %>% 
  ggplot(aes(x = roseburia_2, y = value)) +
  geom_smooth(method = "lm", se = FALSE) +
  geom_point(aes(color = treatment)) +
  scale_x_continuous(transform = scales::pseudo_log_trans()) +
  facet_wrap(~var, scale = "free_y") +
  labs(
    x     = "Roseburia_2", 
    y     = "Cardiometabolic measures (mg/dL)",
    color = "Treatment"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")


# Linear model for Shannon index ------------------------------------------

# Define outcomes
outcomes   <- c("delta_chol", "delta_ldl", "delta_hdl", "delta_apob")

# Center %body fat at its median value of 43%
summary(df_delta$pct_fat_b)

# Run linear model with %fat and its interaction with Shannon index
# None of interaction terms was significant 
lm_fits <- outcomes %>% 
  paste("~ delta_shannon * I(pct_fat_b - 43) + group") %>% 
  lapply(lm, data = df_delta) %>% 
  setNames(outcomes)

# Estimated beta coefficients
lm_fits %>% lapply(summary)

# Run linear model without %fat and its interaction
# Significant positive association in total chol, LDL, and ApoB
# None of interaction terms was significant 
lm_fits <- outcomes %>% 
  paste("~ delta_shannon + I(pct_fat_b - 43) + group") %>% 
  lapply(lm, data = df_delta) %>% 
  setNames(outcomes)

# Estimated beta coefficients
lm_fits %>% lapply(summary)

# Tidy each model with 95% CIs, stack into one long data frame
coef_tbl <- lm_fits %>% 
  imap_dfr(~ tidy(.x, conf.int = TRUE) %>% mutate(outcome = .y))

term_labels <- c(
  "(Intercept)"        = "Intercept",
  "delta_shannon"      = "Δ Shannon index",
  "I(pct_fat_b - 43)"  = "%Body fat (centered)",
  "group"              = "Sequence group"
)

outcome_labels <- c(
  delta_chol = "Total cholesterol", delta_ldl = "LDL",
  delta_hdl  = "HDL",               delta_apob = "ApoB"
)

coef_long <- coef_tbl %>% 
  mutate(
    term    = factor(term, levels = names(term_labels), labels = term_labels),
    outcome = factor(outcome, levels = names(outcome_labels), labels = outcome_labels)
  ) %>% 
  transmute(
    Outcome    = outcome,
    Term       = term,
    Beta       = sprintf("%.3f", estimate),
    `Lower CI` = sprintf("%.3f", conf.low),
    `Upper CI` = sprintf("%.3f", conf.high),
    `P-value`  = pval_4dp(p.value)
  ) %>% 
  mutate(Outcome = if_else(duplicated(Outcome), "", as.character(Outcome)))

coef_long %>% 
  kable(align = c("l", "l", "c", "c", "c", "c"))


# Linear mixed model for Shannon index ------------------------------------

# Exclude baseline
# Create within- and between-subject terms
baseline_fat <- df %>% 
  filter(visit == 0) %>% 
  select(id, pct_fat_b = pct_fat)

df_long <- df %>% 
  left_join(baseline_fat, by = "id") %>% 
  filter(treatment %in% c("mac", "control")) %>% 
  group_by(id) %>% 
  mutate(
    shannon_between = mean(shannon),
    shannon_within  = shannon - shannon_between,
    roseburia_2_between = mean(roseburia_2),
    roseburia_2_within  = roseburia_2 - roseburia_2_between
  ) %>% 
  ungroup()

# Mixed-model equivalent of elta lm() approach

# Define outcomes
outcomes   <- c("chol", "ldl", "hdl", "apob")

# Run linear mixed model with %fat and its interaction with Shannon index
# None of interaction terms was significant 
lmer_fits_intx <- outcomes %>% 
  paste("~ treatment + group + shannon_within * I(pct_fat_b - 43) + shannon_between + (1 | id)") %>% 
  lapply(lmer, data = df_long) %>% 
  setNames(outcomes)

lmer_fits_intx %>% lapply(summary)

# Drop the interaction term 
lmer_fits <- outcomes %>% 
  paste("~ treatment + group + shannon_within + I(pct_fat_b - 43) + shannon_between + (1 | id)") %>% 
  lapply(lmer, data = df_long) %>% 
  setNames(outcomes)

lmer_fits %>% lapply(summary)

# Tidy each mixed model's fixed effects, with 95% CIs
coef_tbl_mixed <- lmer_fits %>% 
  imap_dfr(~ tidy(.x, effects = "fixed", conf.int = TRUE) %>% mutate(outcome = .y))

# Term labels -- check unique(coef_tbl_mixed$term) and adjust if
# "treatmentmac" doesn't match your factor's reference level
term_labels <- c(
  "(Intercept)"       = "Intercept",
  "treatmentmac"      = "Treatment (Mac vs. Control)",
  "group"             = "Sequence group",
  "shannon_within"    = "Shannon index (within-subject)",
  "I(pct_fat_b - 43)" = "%Body fat (centered)",
  "shannon_between"   = "Shannon index (between-subject)"
)

outcome_labels <- c(
  chol = "Total cholesterol", ldl = "LDL",
  hdl  = "HDL",               apob = "ApoB"
)

coef_long_mixed <- coef_tbl_mixed %>% 
  mutate(
    sig     = p.value < 0.05 & term != "(Intercept)",
    term    = factor(term, levels = names(term_labels), labels = term_labels),
    outcome = factor(outcome, levels = names(outcome_labels), labels = outcome_labels)
  ) %>% 
  transmute(
    Outcome    = outcome,
    Term       = term,
    Beta       = if_else(sig, sprintf("**%.3f**", estimate), sprintf("%.3f", estimate)),
    `Lower CI` = sprintf("%.3f", conf.low),
    `Upper CI` = sprintf("%.3f", conf.high),
    `P-value`  = if_else(sig, sprintf("**%s**", pval_4dp(p.value)), pval_4dp(p.value))
  ) %>% 
  mutate(Outcome = if_else(duplicated(Outcome), "", as.character(Outcome)))

coef_long_mixed %>% 
  kable(align = c("l", "l", "c", "c", "c", "c"))

# Linear model for Roseburia_2 --------------------------------------------

# Define outcomes
outcomes   <- c("delta_chol", "delta_ldl", "delta_hdl", "delta_apob")

# Center %body fat at its median value of 43%
summary(df_delta$pct_fat_b)

# Run linear model with %fat and its interaction with Roseburia_2
# Interaction was significant for CHOL (p = 0.0278) and LDL (p = 0.0205) 
lm_fits <- outcomes %>% 
  paste("~ I(delta_roseburia_2 / 100) * I(pct_fat_b - 43) + group") %>% 
  lapply(lm, data = df_delta) %>% 
  setNames(outcomes)

# Estimated beta coefficients
lm_fits %>% lapply(summary)

# Tidy each model with 95% CIs, stack into one long data frame
coef_tbl <- lm_fits %>% 
  imap_dfr(~ tidy(.x, conf.int = TRUE) %>% mutate(outcome = .y))

term_labels <- c(
  "(Intercept)"                                 = "Intercept",
  "I(delta_roseburia_2/100)"                    = "Δ Roseburia_2 (per 100 units)",
  "I(pct_fat_b - 43)"                           = "%Body fat (centered)",
  "group"                                       = "Sequence group",
  "I(delta_roseburia_2/100):I(pct_fat_b - 43)"  = "Δ Roseburia_2 \u00d7 %Body fat"
)

outcome_labels <- c(
  delta_chol = "Δ Total cholesterol", 
  delta_ldl = "Δ LDL",
  delta_hdl  = "Δ HDL",               
  delta_apob = "Δ ApoB"
)

coef_long <- coef_tbl %>% 
  mutate(
    sig     = p.value < 0.05 & term != "(Intercept)",
    term    = factor(term, levels = names(term_labels), labels = term_labels),
    outcome = factor(outcome, levels = names(outcome_labels), labels = outcome_labels)
  ) %>% 
  transmute(
    Outcome    = outcome,
    Term       = term,
    Beta       = if_else(sig, sprintf("**%.3f**", estimate), sprintf("%.3f", estimate)),
    `Lower CI` = sprintf("%.3f", conf.low),
    `Upper CI` = sprintf("%.3f", conf.high),
    `P-value`  = if_else(sig, sprintf("**%s**", pval_4dp(p.value)), pval_4dp(p.value))
  ) %>% 
  mutate(Outcome = if_else(duplicated(Outcome), "", as.character(Outcome)))

coef_long %>% 
  kable(align = c("l", "l", "c", "c", "c", "c"))


# Mean %body fat within each side of the median split (mirrors the paper's grouping)
fat_means <- df_delta %>% 
  mutate(fat_grp = if_else(pct_fat_b < 43, "Low (<43%)", "High (≥43%)")) %>% 
  group_by(fat_grp) %>% 
  summarise(mean_fat = mean(pct_fat_b), .groups = "drop")

fat_means

# Slope of delta_roseburia_2 on each outcome, at each group's mean %body fat
slopes <- lm_fits %>% 
  lapply(function(m) {
    emtrends(m, ~ pct_fat_b, var = "delta_roseburia_2",
             at = list(pct_fat_b = fat_means$mean_fat),
             data = df_delta) %>% 
      summary(infer = TRUE) %>% 
      mutate(
        delta_roseburia_2.trend = delta_roseburia_2.trend * 100,
        SE       = SE * 100,
        lower.CL = lower.CL * 100,
        upper.CL = upper.CL * 100
      )
  })

slopes

# Build a clean summary table of the slopes
outcome_labels <- c(
  delta_chol = "Total cholesterol", delta_ldl = "LDL",
  delta_hdl  = "HDL",               delta_apob = "ApoB"
)

slopes_tbl <- slopes %>% 
  imap_dfr(~ as_tibble(.x) %>% mutate(outcome = .y)) %>% 
  mutate(
    outcome   = factor(outcome, levels = names(outcome_labels), labels = outcome_labels),
    fat_group = if_else(pct_fat_b < 43, "<43%", "\u226543%"),
    fat_group = factor(fat_group, levels = c("<43%", "\u226543%"))
  ) %>% 
  arrange(outcome, fat_group) %>% 
  transmute(
    Outcome            = outcome,
    `%Body fat group`  = fat_group,
    Beta       = sprintf("%.3f", delta_roseburia_2.trend),
    `Lower CI` = sprintf("%.3f", lower.CL),
    `Upper CI` = sprintf("%.3f", upper.CL),
    `P-value`  = pval_4dp(p.value)
  ) %>% 
  mutate(Outcome = if_else(duplicated(Outcome), "", as.character(Outcome)))

slopes_tbl %>% 
  kable(align = c("l", "l", "c", "c", "c", "c"))


# Linear mixed model for Roseburia_2 --------------------------------------

# Mixed-model equivalent of elta lm() approach
# Define outcomes
outcomes   <- c("chol", "ldl", "hdl", "apob")

# Run linear mixed model with %fat and its interaction with Roseburia_2
# Significant interaction terms in TC, LDL, and ApoB 
lmer_fits_intx <- outcomes %>% 
  paste("~ treatment + group + I(roseburia_2_within / 100) * I(pct_fat_b - 43) + I(roseburia_2_between / 100) + (1 | id)") %>% 
  lapply(lmer, data = df_long) %>% 
  setNames(outcomes)

lmer_fits_intx %>% lapply(summary)

# Tidy each mixed model's fixed effects, with 95% CIs
coef_tbl_mixed <- lmer_fits_intx %>% 
  imap_dfr(~ tidy(.x, effects = "fixed", conf.int = TRUE) %>% mutate(outcome = .y))

# Term labels -- check unique(coef_tbl_mixed$term) and adjust names below
# if any don't match (e.g. "treatmentmac" depends on which level of
# `treatment` R picked as the reference)
term_labels <- c(
  "(Intercept)"                                 = "Intercept",
  "treatmentmac"                                = "Treatment (Mac vs. Control)",
  "group"                                        = "Sequence group",
  "I(roseburia_2_within/100)"                   = "Roseburia_2 (within-subject, per 100 units)",
  "I(pct_fat_b - 43)"                            = "%Body fat (centered)",
  "I(roseburia_2_between/100)"                  = "Roseburia_2 (between-subject, per 100 units)",
  "I(roseburia_2_within/100):I(pct_fat_b - 43)" = "Roseburia_2 (within) \u00d7 %Body fat"
)

outcome_labels <- c(
  chol = "Total cholesterol", ldl = "LDL",
  hdl  = "HDL",               apob = "ApoB"
)

coef_long_mixed <- coef_tbl_mixed %>% 
  mutate(
    sig     = p.value < 0.05 & term != "(Intercept)",
    term    = factor(term, levels = names(term_labels), labels = term_labels),
    outcome = factor(outcome, levels = names(outcome_labels), labels = outcome_labels)
  ) %>% 
  transmute(
    Outcome    = outcome,
    Term       = term,
    Beta       = if_else(sig, sprintf("**%.3f**", estimate), sprintf("%.3f", estimate)),
    `Lower CI` = sprintf("%.3f", conf.low),
    `Upper CI` = sprintf("%.3f", conf.high),
    `P-value`  = if_else(sig, sprintf("**%s**", pval_4dp(p.value)), pval_4dp(p.value))
  ) %>% 
  mutate(Outcome = if_else(duplicated(Outcome), "", as.character(Outcome)))

coef_long_mixed %>% 
  kable(align = c("l", "l", "c", "c", "c", "c"))

slopes_mixed <- lmer_fits_intx %>% 
  lapply(function(m) {
    emtrends(m, ~ pct_fat_b, var = "roseburia_2_within",
             at = list(pct_fat_b = fat_means$mean_fat),
             data = df_long) %>% 
      summary(infer = TRUE) %>% 
      mutate(
        roseburia_2_within.trend = roseburia_2_within.trend * 100,
        SE       = SE * 100,
        lower.CL = lower.CL * 100,
        upper.CL = upper.CL * 100
      )
  })

slopes_mixed

slopes_tbl <- slopes_mixed %>% 
  imap_dfr(~ as_tibble(.x) %>% mutate(outcome = .y)) %>% 
  mutate(
    outcome   = factor(outcome, levels = names(outcome_labels), labels = outcome_labels),
    fat_group = if_else(pct_fat_b < 43, "<43%", "\u226543%"),
    fat_group = factor(fat_group, levels = c("<43%", "\u226543%"))
  ) %>% 
  arrange(outcome, fat_group) %>% 
  transmute(
    Outcome            = outcome,
    `%Body fat group`  = fat_group,
    Beta       = sprintf("%.3f", roseburia_2_within.trend),
    `Lower CI` = sprintf("%.3f", lower.CL),
    `Upper CI` = sprintf("%.3f", upper.CL),
    `P-value`  = pval_4dp(p.value)
  )

slopes_tbl %>% 
  kable(align = c("l", "l", "c", "c", "c", "c"))


# Influlence statistics ---------------------------------------------------

# Re-run mixed models for TC, LDL and ApoB
m_chol <- lmer(chol ~ treatment + group + I(roseburia_2_within / 100) * I(pct_fat_b - 43) + I(roseburia_2_between / 100) + (1 | id), data = df_long)
m_ldl  <- lmer(ldl  ~ treatment + group + I(roseburia_2_within / 100) * I(pct_fat_b - 43) + I(roseburia_2_between / 100) + (1 | id), data = df_long)
m_apob <- lmer(apob ~ treatment + group + I(roseburia_2_within / 100) * I(pct_fat_b - 43) + I(roseburia_2_between / 100) + (1 | id), data = df_long)

infl_chol <- influence(m_chol, group = "id")
cooks.distance(infl_chol)
dfbetas(infl_chol)

plot(infl_chol, which = "cook")
plot(infl_chol, which = "dfbetas", parameters = "I(roseburia_2_within/100):I(pct_fat_b - 43)")

# Cook's distince
cooks_df <- as.data.frame(cooks.distance(infl_chol)) %>%
  rownames_to_column("id") %>%
  rename(cooks_d = 2)

# DFBETA for the interaction term
dfbetas_mat <- dfbetas(infl_chol)

dfbetas_df <- as.data.frame(dfbetas_mat) %>%
  rownames_to_column("id") %>%
  select(id, dfbetas_intx = `I(roseburia_2_within/100):I(pct_fat_b - 43)`)

# Combine Cook's D and DFBETA and apply thresholds
n <- nrow(cooks_df)
cook_threshold    <- 4 / n
dfbetas_threshold <- 2 / sqrt(n)

diag_tbl <- cooks_df %>%
  left_join(dfbetas_df, by = "id") %>%
  mutate(
    id           = factor(id, levels = as.character(sort(as.integer(id)))),
    cooks_d      = round(cooks_d, 3),
    dfbetas_int  = round(dfbetas_intx, 3),
    flag_cooks   = cooks_d > cook_threshold,
    flag_dfbetas = abs(dfbetas_int) > dfbetas_threshold,
    flagged      = flag_cooks | flag_dfbetas
  ) %>%
  arrange(desc(cooks_d))

print(diag_tbl)
summary(diag_tbl$dfbetas_intx)

# Show flagged IDs
diag_tbl %>% filter(flagged)


# --- Cook's distance plot -----------------------------------------------------
ggplot(diag_tbl, aes(x = id, y = cooks_d, fill = flag_cooks)) +
  geom_col() +
  geom_hline(yintercept = cook_threshold, linetype = "dashed", color = "red") +
  scale_fill_manual(values = c(`TRUE` = "firebrick", `FALSE` = "grey40"), guide = "none") +
  labs(
    x     = "Participant ID",
    y     = "Cook's Distance",
    title = "Influence diagnostics: Cook's Distance (TC mixed model)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# --- DFBETAS plot for the Roseburia_2 (within) x %body fat interaction ------
diag_tbl %>% 
  ggplot(aes(x = id, y = dfbetas_intx, fill = flag_dfbetas)) +
  geom_col() +
  geom_hline(yintercept = c(-dfbetas_threshold, dfbetas_threshold), linetype = "dashed", color = "red") +
  scale_fill_manual(values = c(`TRUE` = "firebrick", `FALSE` = "grey40"), guide = "none") +
  labs(
    x     = "Participant ID",
    y     = "DFBETAS: Roseburia_2 (within) \u00d7 %Body fat",
    title = "Influence diagnostics: DFBETAS for the interaction term (TC mixed model)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# Make it into a function
plot_influence <- function(infl,
                           interaction_term = "I(roseburia_2_within/100):I(pct_fat_b - 43)",
                           outcome_label) {
  
  cooks_df <- as.data.frame(cooks.distance(infl)) %>%
    rownames_to_column("id") %>%
    rename(cooks_d = 2)
  
  dfbetas_mat <- dfbetas(infl)
  if (!interaction_term %in% colnames(dfbetas_mat)) {
    stop(
      "interaction_term '", interaction_term, "' not found in dfbetas(infl).\n",
      "Available columns: ", paste(colnames(dfbetas_mat), collapse = ", ")
    )
  }
  dfbetas_df <- as.data.frame(dfbetas_mat) %>%
    rownames_to_column("id") %>%
    select(id, dfbetas_intx = all_of(interaction_term))
  
  n <- nrow(cooks_df)
  cook_threshold    <- 4 / n
  dfbetas_threshold <- 2 / sqrt(n)
  
  diag_df <- cooks_df %>%
    left_join(dfbetas_df, by = "id") %>%
    mutate(
      id           = factor(id, levels = as.character(sort(as.integer(id)))),
      flag_cooks   = cooks_d > cook_threshold,
      flag_dfbetas = abs(dfbetas_intx) > dfbetas_threshold
    )
  
  p_cooks <- ggplot(diag_df, aes(x = id, y = cooks_d, color = flag_cooks)) +
    geom_segment(aes(x = id, xend = id, y = 0, yend = cooks_d), linewidth = 1) +
    geom_point(size = 3) +
    geom_hline(yintercept = cook_threshold, linetype = "dashed", color = "red") +
    scale_color_manual(values = c(`TRUE` = "firebrick", `FALSE` = "grey40"), guide = "none") +
    labs(
      x     = "Participant ID",
      y     = "Cook's Distance",
      title = paste0("Influence diagnostics: Cook's Distance (", outcome_label, " mixed model)")
    ) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
  
  p_dfbetas <- ggplot(diag_df, aes(x = id, y = dfbetas_intx, color = flag_dfbetas)) +
    geom_segment(aes(x = id, xend = id, y = 0, yend = dfbetas_intx), linewidth = 1) +
    geom_point(size = 3) +
    geom_hline(yintercept = c(-dfbetas_threshold, dfbetas_threshold), linetype = "dashed", color = "red") +
    geom_hline(yintercept = 0, color = "grey70") +
    scale_color_manual(values = c(`TRUE` = "firebrick", `FALSE` = "grey40"), guide = "none") +
    labs(
      x     = "Participant ID",
      y     = "DFBETAS: Roseburia_2 (within) \u00d7 %Body fat",
      title = paste0("Influence diagnostics: DFBETAS for interaction term (", outcome_label, " mixed model)")
    ) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5))
  
  # print(p_cooks)
  print(p_dfbetas)
  
  invisible(list(data = diag_df, cooks_plot = p_cooks, dfbetas_plot = p_dfbetas))
}

infl_chol <- influence(m_chol, group = "id")
infl_ldl  <- influence(m_ldl,  group = "id")
infl_apob <- influence(m_apob, group = "id")

res_chol <- plot_influence(infl_chol, outcome_label = "TC")
res_ldl  <- plot_influence(infl_ldl,  outcome_label = "LDL")
res_apob <- plot_influence(infl_apob, outcome_label = "ApoB")

# ID = 5; Control-mac group
# Largest decreases in TC, LDL, HDL, and ApoB
# 6th largest increase in Roseburia_2
df %>% 
  filter(id == 5) %>% 
  select(id, group_lab, phase, treatment, pct_fat, chol, ldl, hdl, apob, shannon, roseburia_2)

df_delta %>% 
  filter(id == 5) %>% 
  select(id, gender, group, group_lab, pct_fat_b, delta_chol, delta_ldl, delta_hdl, delta_apob, delta_shannon, delta_roseburia_2)

# ID = 6; mac-control group; 
# Second largest decreases in TC and LDL
# Third largest increases in Roseburia_2
df %>%
  filter(visit != 0) %>% 
  filter(id == 6) %>% 
  select(id, group_lab, phase, treatment, pct_fat, chol, ldl, hdl, apob, shannon, roseburia_2)

df_delta %>% 
  filter(id == 6) %>% 
  select(id, gender, group, group_lab, pct_fat_b, delta_chol, delta_ldl, delta_hdl, delta_apob, delta_shannon, delta_roseburia_2)

df_delta %>% 
  select(delta_chol, delta_ldl, delta_hdl, delta_apob, delta_shannon, delta_roseburia_2) %>% 
  summary()

df_delta %>% 
  select(id, delta_chol, delta_ldl, delta_hdl, delta_apob, delta_shannon, delta_roseburia_2) %>% 
  arrange(-delta_roseburia_2) 

# Sensitivity analysis excluding influential obs --------------------------

# Mixed-model equivalent of elta lm() approach
# Define outcomes
outcomes   <- c("chol", "ldl", "hdl", "apob")

# Run linear mixed model with %fat and its interaction with Roseburia_2
# Removing ID = 5
lmer_fits_intx_sens_5 <- list()
for (oc in outcomes) {
  frm <- as.formula(paste(oc, "~ treatment + group + I(roseburia_2_within / 100) * I(pct_fat_b - 43) + I(roseburia_2_between / 100) + (1 | id)"))
  lmer_fits_intx_sens_5[[oc]] <- eval(bquote(
    lmer(.(frm), data = df_long, subset = !(id %in% c(5)))
  ))
}
names(lmer_fits_intx_sens_5) <- outcomes

lmer_fits_intx_sens_5[["apob"]] %>% summary()

# Make it to a kable
term_labels <- c(
  "(Intercept)"                                 = "Intercept",
  "treatmentmac"                                = "Treatment (Mac vs. Control)",
  "group"                                       = "Sequence group",
  "I(roseburia_2_within/100)"                   = "Roseburia_2 (within-subject, per 100 units)",
  "I(pct_fat_b - 43)"                           = "%Body fat (centered)",
  "I(roseburia_2_between/100)"                  = "Roseburia_2 (between-subject, per 100 units)",
  "I(roseburia_2_within/100):I(pct_fat_b - 43)" = "Roseburia_2 (within) \u00d7 %Body fat"
)

coef_tbl_mixed_sens5_apob <- lmer_fits_intx_sens_5$apob %>% 
  tidy(effects = "fixed", conf.int = TRUE)

coef_tbl_mixed_sens5_apob %>% 
  mutate(
    sig  = p.value < 0.05 & term != "(Intercept)",
    term = factor(term, levels = names(term_labels), labels = term_labels)
  ) %>% 
  transmute(
    Term       = term,
    Beta       = if_else(sig, sprintf("**%.3f**", estimate), sprintf("%.3f", estimate)),
    `Lower CI` = sprintf("%.3f", conf.low),
    `Upper CI` = sprintf("%.3f", conf.high),
    `P-value`  = if_else(sig, sprintf("**%s**", pval_4dp(p.value)), pval_4dp(p.value))
  ) %>% 
  kable(align = c("l", "c", "c", "c", "c"))

# Removing ID = 6 
lmer_fits_intx_sens_6 <- list()
for (oc in outcomes) {
  frm <- as.formula(paste(oc, "~ treatment + group + I(roseburia_2_within / 100) * I(pct_fat_b - 43) + I(roseburia_2_between / 100) + (1 | id)"))
  lmer_fits_intx_sens_6[[oc]] <- eval(bquote(
    lmer(.(frm), data = df_long, subset = !(id %in% c(6)))
  ))
}

# Make it to a kable
coef_tbl_mixed_sens6_ldl <- lmer_fits_intx_sens_6$ldl %>% 
  tidy(effects = "fixed", conf.int = TRUE)

coef_tbl_mixed_sens6_ldl %>% 
  mutate(
    sig  = p.value < 0.05 & term != "(Intercept)",
    term = factor(term, levels = names(term_labels), labels = term_labels)
  ) %>% 
  transmute(
    Term       = term,
    Beta       = if_else(sig, sprintf("**%.3f**", estimate), sprintf("%.3f", estimate)),
    `Lower CI` = sprintf("%.3f", conf.low),
    `Upper CI` = sprintf("%.3f", conf.high),
    `P-value`  = if_else(sig, sprintf("**%s**", pval_4dp(p.value)), pval_4dp(p.value))
  ) %>% 
  kable(align = c("l", "c", "c", "c", "c"))

