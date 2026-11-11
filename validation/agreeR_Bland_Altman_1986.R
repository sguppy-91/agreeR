#agreeR_Bland_Altman_1986.R

# This script checks the implementation of 95% limits of agreement and 95% confidence intervals
# against the data reported in Bland & Altman (1986). As per the original paper, only the first
# measurement for both the Wright Flow Meter and the Mini Wright Flow Meter has been used.

# Import data
ba_master <- read_csv("validation/Bland_Altman_1986.csv")

# Check assumptions
ba_master <- ba_master |>
  select(Wright_T1, Mini_T1) |>
  mutate(difference = Wright_T1 - Mini_T1, average = (Wright_T1 + Mini_T1) / 2)

ggplot(ba_master, aes(x = difference)) +
  geom_density() +
  theme_classic()

ggplot(ba_master, aes(x = average, y = difference)) +
  geom_point() +
  scale_y_continuous(breaks = seq(-100, 100, 25)) +
  theme_classic()

set.seed(549)
ba_bca <- ba_loa(ba_master, "Wright_T1", "Mini_T1", R = 10000, ci_type = "bca")

ba_perc <- ba_loa(
  ba_master,
  "Wright_T1",
  "Mini_T1",
  R = 10000,
  ci_type = "perc"
)

knitr::kable(ba_bca, digits = 3)

knitr::kable(ba_perc, digits = 3)
