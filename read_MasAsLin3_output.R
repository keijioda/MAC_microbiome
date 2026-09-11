
# Required packages
pacs <- c("tidyverse")
sapply(pacs, require, character.only = TRUE)

# Read MasAsLin3 output
path <- "data/maaslin3_crossover_output_both_models_small_random_effect/adjusted_main_allvars_n-tss_t-log_p-0.1_q-0.25/"
out <- read_tsv(paste0(path, "all_results.tsv"))

# 1,724 rows x 15 columns
out
names(out)

# Look for diet effect of Roseburia
roseburia_diet <- out %>% 
  filter(metadata == "Diet", model == "abundance") %>% 
  filter(str_detect(feature, regex("roseburia", ignore_case = TRUE)))

# Only 5 of them
roseburia_diet

# Calculate 95% confidence intervals
roseburia_plot_df <- roseburia_diet %>% 
  mutate(
    conf_low  = coef - 1.96 * stderr,
    conf_high = coef + 1.96 * stderr,
    is_target = feature == "Roseburia_2",
    feature   = fct_reorder(feature, coef)
  )

# Forest plot of beta for Roseburia
ggplot(roseburia_plot_df, aes(x = coef, y = feature, color = is_target)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = conf_low, xmax = conf_high), height = 0.15) +
  geom_point(size = 3) +
  scale_color_manual(values = c(`TRUE` = "firebrick", `FALSE` = "grey40"), guide = "none") +
  labs(
    x = "Diet effect (Mac vs. Control), coefficient \u00b1 95% CI",
    y = NULL,
    title = "Diet effect across Roseburia-assigned ASVs",
    subtitle = "Highlighted: Roseburia_2 (FDR-significant)"
  ) +
  theme_bw(base_size = 12)
