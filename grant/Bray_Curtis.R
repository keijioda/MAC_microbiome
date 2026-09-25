
# For grant proposal

# Setup -------------------------------------------------------------------

# Packages used
pacs <- c(
  "tidyverse",
  "readxl", 
  "haven",
  "vegan",
  "beeswarm"
)

sapply(pacs, require, character.only = TRUE)

# Read previous MAC data --------------------------------------------------

# Needed to extract treatment sequence
mac0 <- read_spss("./data/MAC Endpoint data with baseline values 102121.sav") %>% 
  janitor::clean_names()

# Variables needed
seq <- mac0 %>% 
  select(id, group, phase, visit, treatment)

# Distinct data with ID, Group
# n = 35
seq_distinct <- seq %>% 
  select(id, group) %>% 
  distinct()

# Use only control-first group
# Need to compare at baseline and at the end of control phase
ctrl_first_ids <- seq_distinct %>% filter(group == 2) %>% pull(id)
ctrl_first_ids

need_columns <- sprintf("%02.0f", ctrl_first_ids) %>% paste0("MAC", .)
need_columns

# Read microbiome data ----------------------------------------------------

# 4166 rows x 112 columns
mb <- read_excel("./data/human_mac_study_abundance_data.xls")  

# Create abundance matrix
# Need rows = samples, columns = taxa
abundance_matrix <- mb %>% 
  select(starts_with(need_columns)) %>% 
  select(ends_with(c("v0", "v4"))) %>% 
  as.matrix() %>% 
  t()

# Rows = samples, columns = taxa
dim(abundance_matrix)

# Bray-Curtis dissimilarity / similarity -----------------------------------

# Dissimilarity score
bc_dissim <- vegdist(abundance_matrix, method = "bray") %>% 
  as.matrix()

# Similarity score
bc_sim <- 1 - bc_dissim

# Within-person BC similarity
sample_meta <- tibble(sample_id = rownames(bc_sim)) %>% 
  extract(sample_id, into = c("id_chr", "visit"),
          regex = "^(MAC\\d+)_p\\d+(v\\d+)$", remove = FALSE)

within_person_bc <- bc_sim %>% 
  as_tibble(rownames = "sample_1") %>% 
  pivot_longer(-sample_1, names_to = "sample_2", values_to = "bc_sim") %>% 
  left_join(sample_meta, by = c("sample_1" = "sample_id")) %>% 
  rename(id_1 = id_chr, visit_1 = visit) %>% 
  left_join(sample_meta, by = c("sample_2" = "sample_id")) %>% 
  rename(id_2 = id_chr, visit_2 = visit) %>% 
  filter(id_1 == id_2, visit_1 == "v0", visit_2 == "v4") %>% 
  select(id = id_1, bc_sim)

within_person_bc

# Between-person BC similarity
between_person_bc <- bc_sim %>% 
  as_tibble(rownames = "sample_1") %>% 
  pivot_longer(-sample_1, names_to = "sample_2", values_to = "bc_sim") %>% 
  left_join(sample_meta, by = c("sample_1" = "sample_id")) %>% 
  rename(id_1 = id_chr, visit_1 = visit) %>% 
  left_join(sample_meta, by = c("sample_2" = "sample_id")) %>% 
  rename(id_2 = id_chr, visit_2 = visit) %>% 
  filter(visit_1 == "v0", visit_2 == "v0", id_1 < id_2) %>% 
  select(id_1, id_2, bc_sim)

between_person_bc

# Summary statictics
bc_summary <- bind_rows(
  within_person_bc  %>% mutate(group = "Within-person"),
  between_person_bc %>% mutate(group = "Between-person")
) %>%
  group_by(group) %>%
  summarise(
    n      = n(),
    mean   = mean(bc_sim),
    sd     = sd(bc_sim),
    median = median(bc_sim),
    q1     = quantile(bc_sim, 0.25),
    q3     = quantile(bc_sim, 0.75)
  )

bc_summary

# PERMANOVA ---------------------------------------------------------------

# PERMANOVA based on disimilarity
# Covariate table aligned to the rows of bc_dissim, in the same order
sample_info <- sample_meta %>% 
  filter(sample_id %in% rownames(bc_dissim)) %>% 
  arrange(match(sample_id, rownames(bc_dissim)))

# Does composition cluster by subject?
set.seed(123)
adonis_result <- adonis2(
  as.dist(bc_dissim) ~ id_chr,
  data = sample_info,
  permutations = 9999
)

# Subject effect is highly significant
adonis_result


# Boxplot with beeswarm ---------------------------------------------------

r2_val <- adonis_result$R2[1]
f_val  <- adonis_result$F[1]
p_val  <- adonis_result$`Pr(>F)`[1]

p_label <- if (p_val <= 0.0001) "p < 0.0001" else paste0("p = ", format(p_val, digits = 2))
perm_label <- sprintf("PERMANOVA: R² = %.3f, F = %.2f, %s", r2_val, f_val, p_label)

# Box plot
bind_rows(
  within_person_bc  %>% mutate(comparison = "within-person")  %>% select(comparison, bc_sim),
  between_person_bc %>% mutate(comparison = "between-person") %>% select(comparison, bc_sim)
) %>% 
  ggplot(aes(x = comparison, y = bc_sim)) +
  geom_boxplot() +
  geom_beeswarm(aes(color = comparison)) +
  labs(
    x = NULL, 
    y = "Bray-Curtis Similarity",     
    title = "Bray-Curtis Similarity: Within- vs. Between-Person",
    subtitle = perm_label
  ) +
  theme(legend.position = "none")
