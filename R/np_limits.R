#' Non-parametric centile limits of agreement
#'
#' Computes the median bias and empirical centile limits of agreement between
#' two measurement methods, together with bootstrap confidence intervals for
#' each estimate.
#'
#' @details
#' The confidence intervals for this analysis workflow are estimated by bootstrap resampling of the paired differences with `R`
#' replicates. The default `ci_type = "bca"` gives bias-corrected and accelerated intervals, which are preferred when the distribution
#' of differences is skewed; `ci_type = "perc"` gives ordinary percentile intervals. BCa intervals can be unstable with very small samples,
#' in which case `ci_type = "perc"` may be a safer choice.
#'
#' Measurements must be paired, with a single measurement per participant per method.
#'
#'
#' @param data dataframe containing the paired measurements.
#' @param reference Name of the reference method column.
#' @param comparison Name of the comparison method column.
#' @param conf Confidence level for the limits of agreement and their bootstrap confidence intervals.
#' @param R Number of bootstrap replicates passed to [boot::boot()].
#' @param na_rm Logical. If `TRUE`, rows with missing values are dropped before analysis.
#' @param ci_type Type of bootstrap confidence interval: `"perc"` (percentile) or `"bca"` (bias-corrected and accelerated, the default), passed to [boot::boot.ci()].
#'
#' @return A tibble with one row per estimate (median bias, lower LOA, upper LOA) giving the point estimate and its confidence interval.
#'
#' @references
#' Bland, J. M., & Altman, D. G. (1999). Measuring agreement in method comparison studies. Statistical Methods in Medical Research, 8(2), 135–160.
#'
#' @seealso [ba_loa()] for Bland-Altman 95% limits of agreement; [olp()] for ordinary least products regression; [equiv_test()] for two one-sided tests of equivalence.
#'
#' @export

centile_loa <- function(
  data,
  reference,
  comparison,
  conf = 0.95,
  R = 2000,
  na_rm = TRUE,
  ci_type = c("bca", "perc")
) {
  alpha <- 1 - conf

  lower_prob <- alpha / 2
  upper_prob <- 1 - alpha / 2

  df <- tidyr::tibble(
    difference = data[[reference]] - data[[comparison]]
  )

  if (na_rm) {
    df <- tidyr::drop_na(df)
  }

  ci_type <- match.arg(ci_type, c("perc", "bca"))
  # boot.ci names its result component "percent" for type "perc"
  ci_component <- switch(ci_type, perc = "percent", bca = "bca")

  stat <- function(d, i) {
    x <- d$difference[i]

    bias <- stats::median(x)

    lower <- stats::quantile(
      x,
      probs = lower_prob,
      type = 7
    )

    upper <- stats::quantile(
      x,
      probs = upper_prob,
      type = 7
    )

    c(
      "Median bias" = bias,
      "Lower LOA" = lower,
      "Upper LOA" = upper
    )
  }

  boot_out <- boot::boot(df, statistic = stat, R = R)

  purrr::map(seq_along(boot_out$t0), \(i) {
    b <- boot::boot.ci(boot_out, type = ci_type, conf = conf, index = i)[[
      ci_component
    ]][4:5]
    tidyr::tibble(
      metric = names(boot_out$t0)[[i]],
      estimate = unname(boot_out$t0)[[i]],
      lower_ci = b[1],
      upper_ci = b[2]
    )
  }) |>
    purrr::list_rbind()
}
