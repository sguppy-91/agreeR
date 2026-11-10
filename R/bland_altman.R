#' Bland-Altman Agreement Analysis
#'
#' Computes the mean bias and 95% limits of agreement (LoA) between two
#' measurement methods, together with bias-corrected and accelerated (BCa)
#' bootstrap confidence intervals for each estimate.
#'
#' @param data A data frame containing the paired measurements from both methods.
#' @param reference Character string naming the column with the reference method measurements.
#' @param comparison Character string naming the column with the comparison method measurements.
#' @param conf Confidence level of the bootstrap confidence intervals.
#' @param R Number of bootstrap replicates passed to [boot::boot()].
#' @param na_rm Logical. If `TRUE`, rows with missing values are dropped before analysis.
#' @param ci_type Type of bootstrap confidence interval: `"perc"` (percentile) or `"bca"`
#'   (bias-corrected and accelerated, the default), passed to [boot::boot.ci()].
#'
#' @return A tibble with one row per estimate (mean bias, lower LoA, upper LoA)
#'   giving the point estimate and its confidence interval.
#'
#' @export
ba_loa <- function(
  data,
  reference,
  comparison,
  conf = 0.95,
  R = 2000,
  na_rm = TRUE,
  ci_type = "bca"
) {
  df <- tidyr::tibble(
    difference = data[[reference]] - data[[comparison]]
  )

  if (na_rm) {
    df <- tidyr::drop_na(df)
  }

  ci_type <- match.arg(ci_type, c("perc", "bca"))
  # boot.ci names its result component "percent" for type = "perc"
  ci_component <- switch(ci_type, perc = "percent", bca = "bca")

  stat <- function(d, i) {
    x <- d$difference[i]

    bias <- mean(x)
    sd_diff <- stats::sd(x)

    c(
      "Mean bias" = bias,
      "Lower LoA" = bias - 1.96 * sd_diff,
      "Upper LoA" = bias + 1.96 * sd_diff
    )
  }

  boot_out <- boot::boot(df, statistic = stat, R = R)

  purrr::map(seq_along(boot_out$t0), \(i) {
    b <- boot::boot.ci(boot_out, type = ci_type, conf = conf, index = i)[[ci_component]][4:5]
    tidyr::tibble(
      metric = names(boot_out$t0)[[i]],
      estimate = unname(boot_out$t0)[[i]],
      lower_ci = b[1],
      upper_ci = b[2]
    )
  }) |>
    purrr::list_rbind()
}
