# agreeR Ludbrook (2012 Test)

# This script checks the implementation of the ordinary least products regression and
# confidence intervals within the agreeR package against the data reported in the
# supplementary material from Ludbrook (2012).

# load packages
library(tidyverse)
library(agreeR)

# Import data
master_sheet <- read_csv("validation/Ludbrook_2012.csv")

# Check assumptions
olp_slope <- sd(master_sheet$Reference) / sd(master_sheet$Comparison)
olp_intercept <- mean(master_sheet$Reference) -
  (olp_slope * mean(master_sheet$Comparison))

master_sheet <- master_sheet |>
  mutate(
    preds = olp_intercept + (olp_slope * Reference),
    resid = Comparison - preds
  )

ggplot(master_sheet, aes(x = resid)) +
  geom_density() +
  theme_classic()


set.seed(412)
bca_ci <- olp(
  master_sheet,
  "Reference",
  "Comparison",
  R = 10000,
  ci_type = "bca"
)

perc_ci <- olp(
  master_sheet,
  "Reference",
  "Comparison",
  R = 10000,
  ci_type = "perc"
)

knitr::kable(bca_ci, digits = 3)

knitr::kable(perc_ci, digits = 3)
