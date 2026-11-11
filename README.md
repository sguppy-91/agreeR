# agreeR: Agreement analyses for method comparison studies

[![R-CMD-check](https://github.com/sguppy-91/agreeR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sguppy-91/agreeR/actions/workflows/R-CMD-check.yaml)

agreeR is a personal R package that automates the statistical workflows I commonly use during my research investigating measurement validity in sport and exercise science.

The package was developed to reduce the need to repeatedly write custom code for common agreement analyses across projects. Development is guided by the practical requirements of my own research rather than by the goal of creating a general-purpose statistical package. 

## Current Functionality
agreeR provides a reproducible workflow for:
- Limits of agreement
- Ordinary least products regression
- Equivalence tests
- Bootstrap confidence intervals

Additional functionality will be added as future research needs arise.

## Installation
```r
# Development version
pak::pak("sguppy-91/agreeR")
```
## Example
```r
library(agreeR)

# Simulated paired measurements from a reference device and comparison methods
set.seed(123)
n <- 40
latent <- rnorm(n, mean = 100, sd = 10)
data <- data.frame(
  force_plate = latent + rnorm(n, 2, 1),
  smartphone  = latent + rnorm(n, 5, 3),
  jump_mat    = latent + rnorm(n, -1, 2),
  mocap       = latent + rnorm(n, 0, 0.5),
  LPT         = latent + rnorm(n, 0.1, 0.4)
)

# Limits of agreement with bias corrected and accelerated 95% confidence intervals 
set.seed(123)
results <- ba_loa(
  data = data,
  reference = "force_plate",
  comparison = "smartphone",
  R = 10000
)

results

# Ordinary least products regression with bias corrected and accelerated 95% confidence intervals
set.seed(123)
results <- olp(
  data = data,
  reference = "force_plate",
  comparison = "jump_mat",
  R = 10000
)

results

# Equivalence test for paired mean difference with bias corrected and accelerated 90% confidence intervals
set.seed(123)
results <- equiv_test(
  data = data,
  reference = "mocap",
  comparison = "LPT",
  lower = -0.05,
  upper = 0.05,
  R = 10000
)

results
```

## Development Status
agreeR is under active development and should be considered experimental software as a result. Although the methods included in the package have been checked against the source literature outlined below, the package has been developed for my own research workflows and may contain implementation errors. Any use of the package should include independently verifying that the methods and results are appropriate for their application and consistent with the relevant source literature.

## AI Disclosure
I use generative AI (Mistral Large 4, Mistral AI; GLM 5.3, Z.ai, hosted by Mistral) as an agentic coding tool during package development. I develop the underlying statistical approach and initial implementation based on the references below before using these tools to assist with code refinement, debugging, and documentation. AI-generated suggestions are reviewed and tested before incorporation into the package.

## References
### Limits of agreement
- Bland, J. M., & Altman, D. G. (1986). Statistical methods for assessing agreement between two methods of clinical measurement. _Lancet_, _327_(8476), 307-310
- Bland, J. M., & Altman, D. G. (2007). Agreement between methods of measurement with multiple observations per individual. _Journal of Biopharmaceutical Statistics_, _17_(4), 571-582.

### Ordinary least products regression
- Ludbrook, J. (1997). Comparing methods of measurement. _Clinical and Experimental Pharmacology and Physiology_, _24_(2), 193-203.
- Ludbrook, J. (2002). Statistical techniques for comparing measurers and methods of measurement: a critical review. _Clinical and Experimental Pharmacology and Physiology_, _29_(7), 527-536.
- Ludbrook, J. (2012). A primer for biomedical scientists on how to execute Model II linear regression analysis. _Clinical and Experimental Pharmacology and Physiology_, _39_(4), 329-335.

### Equivalence Tests
- Schuirmann, D. J. (1987). A comparison of the two one-sided tests procedure and the power approach for assessing equivalence of average bioavailability. _Journal of Pharmacokinetics and Biopharmaceutics_, _15_(6), 657-680.
- Dixon, P. M., Saint-Maurice, P. F., Kim, Y., Hibbing, P., Bai, Y., & Welk, G. J. (2018). A primer on the use of equivalence testing for evaluating measurement agreement. _Medicine and Science in Sports and Exercise_, _50_(4), 837-845.
- Lakens, D. (2017). Equivalence tests: A practical primer for t tests, correlations, and meta-analyses. _Social Psychological and Personality Science_, _8_(4), 355-362.

### Bootstrap resampling
- Davison, A. C., & Hinkley, D. (1997). _Bootstrap methods and their application_. Cambridge University Press
-  Efron, B., & Hastie, T. (2016). Bootstrap confidence intervals. In _Computer Age Statistical Inference: Algorithms, evidence, and data science_ (1st ed., pp. 181-207). Cambridge University Press
