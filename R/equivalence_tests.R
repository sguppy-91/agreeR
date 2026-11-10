#' Equivalence Test for the Mean Difference Between Two Methods
#'
#' Performs the two one-sided tests (TOST) procedure for the mean difference between
#' two measurements, using a bootstrap confidence interval for the mean difference.
#' Equivalence is declared when the confidence interval falls entirely within pre-specified
#' equivalence bounds.
#'
#' @details
#' The equivalence bounds (`lower` and `upper`) are absolute differences on the scale of measurement
#' and must be specified *a priori* on substantive grounds (e.g., the smallest difference
#' considered practically meaningful), not chosen after inspecting the data.
#'
#' The TOST procedure is equivalent to checking whether the confidence interval for the
#' mean difference lies inside the equivalence bounds. For a conventional type I error
#' rate of 5% per one-sided test, this corresponds to a 90% confidence interval, which is
#' why `conf` defaults to .90; changing `conf` changes the implied error rate (e.g., `conf = 0.95`
#' corresponds to 2.5% per one-sided test).
#'
#' The confidence interval is estimated by bootstrap resampling of the paired differences with `R`
#' replicates. The default `ci_type = "bca"` gives bias-corrected and accelerated intervals,
#' which are preferred when the distribution of differences is skewed; `ci_type = "perc"` gives
#' ordinary percentile intervals. BCa intervals can be unstable with very small samples,
#' in which case `ci_type = "perc"` may be a safer choice.
#'
#' Measurements must be paired, with a single measurement per participant per method.
#'
#' @param data A dataframe containing the paired measurements from both methods.
#' @param reference Character string naming the column with the reference method measurements.
#' @param comparison Character string naming the column with the comparison method measurements.
#' @param lower Numeric. Lower equivalence bound for the mean difference, in the units of measurement.
#' @param upper Numeric. Upper equivalence bound for the mean difference, in the units of measurement.
#' @param conf Confidence level of the bootstrap confidence interval. Defaults to 0.90.
#' @param R Number of bootstrap replicates passed to [boot::boot()].
#' @param ci_type Character. Type of bootstrap confidence interval: `"bca"` (default) or `"perc"`.
#' @param na_rm Logical. If `TRUE`, rows with missing values are dropped before analysis
#'
#' @return A tibble with one row and the following columns:
#'   `metric` ("Mean difference"), `estimate` (the mean difference,
#'   reference minus comparison), `lower_ci` and `upper_ci` (the bootstrap
#'   confidence interval), `lower_equivalence` and `upper_equivalence` (the
#'   equivalence bounds), and `equivalent` (logical; `TRUE` if the confidence
#'   interval lies entirely within the bounds).
#'
#' @references
#' Schuirmann, D. J. (1987). A comparison of the two one-sided tests procedure and the
#'  power approach for assessing equivalence of average bioavailability.
#'  *Journal of Pharmacokinetics and Biopharmaceutics*, *15*(6), 657-680.
#'
#' Dixon, P. M., Saint-Maurice, P. F., Kim, Y., Hibbing, P., Bai, Y., & Welk, G. J. (2018).
#'  A primer on the use of equivalence testing for evaluating measurement agreement.
#'  *Medicine and Science in Sports and Exercise*, *50*(4), 837-845.
#'
#' Lakens, D. (2017). Equivalence tests: A practical primer for t tests, correlations,
#'  and meta-analyses. *Social Psychological and Personality Science*, *8*(4), 355-362.
#'
#' Davison, A. C., & Hinkley, D. (1997). *Bootstrap methods and their application*.
#'  Cambridge University Press
#'
#' Efron, B., & Hastie, T. (2016). Bootstrap confidence intervals. In
#'  *Computer Age Statistical Inference: Algorithms, evidence, and data science*
#' (1st ed., pp. 181-207). Cambridge University Press
#'
#' @seealso [olp()] for ordinary least products regression; [ba_loa()] for Bland-Altman limits
#' of agreement
#'
#' @examples
#' set.seed(123)
#' n <- 40
#' method_a <- rnorm(n, 50, 5)
#' method_b <- method_a + rnorm(n, 0, 1)
#' dat <- data.frame(a = method_a, b = method_b)
#'
#' # Bounds of +/- 1 unit: equivalence is supported
#' equiv_test(dat, reference = "a", comparison = "b", lower = -1, upper = 1)
#'
#' # Bounds of +/- 0.1 units: equivalence is not supported
#' equiv_test(dat, reference = "a", comparison = "b", lower = -0.1, upper = 0.1)
#'
#' # Percentile intervals instead of BCa
#' equiv_test(dat, reference = "a", comparison = "b", lower = -1, upper = 1,
#'            ci_type = "perc")
#' @export
equiv_test <- function(
  data,
  reference,
  comparison,
  lower,
  upper,
  conf = 0.90,
  R = 2000,
  na_rm = TRUE,
  ci_type = "bca"
) {
  df <- tidyr::tibble(
    diff = data[[reference]] - data[[comparison]]
  )

  # checks
  if (na_rm) {
    df <- tidyr::drop_na(df)
  }

  if (lower >= upper) {
    stop("lower must be less than upper.")
  }

  ci_type <- match.arg(ci_type, c("perc", "bca"))
  # boot.ci names its result component "percent" for type = "perc"
  ci_component <- switch(ci_type, perc = "percent", bca = "bca")

  stat <- function(d, i) {
    x <- d$diff[i]

    mean(x)
  }

  boot_out <- boot::boot(
    data = df,
    statistic = stat,
    R = R
  )

  ci <- boot::boot.ci(
    boot_out,
    type = ci_type,
    conf = conf
  )[[ci_component]][4:5]

  estimate <- boot_out$t0[[1]]

  tibble::tibble(
    metric = "Mean difference",
    estimate = estimate,
    lower_ci = ci[1],
    upper_ci = ci[2],
    lower_equivalence = lower,
    upper_equivalence = upper,
    equivalent = ci[1] > lower &
      ci[2] < upper
  )
}
