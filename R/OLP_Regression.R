#' Ordinary Least Products Regression
#'
#' Computes the ordinary least products regression slope and intercept
#' between two measurement methods, together with bias-corrected and accelerated (BCa)
#' bootstrap confidence intervals for each parameter estimate
#'
#' @param data A data frame containing the paired measurements from both methods.
#' @param reference Character string naming the column with the reference method measurements.
#' @param comparison Character string naming the column with the comparison methods measurements.
#' @param conf Confidence level of the bootstrap confidence intervals for the slope and intercept.
#' @param R Number of bootstrap replicates passed to [boot::boot()].
#' @param na_rm Logical. If `TRUE`, rows with missing values are dropped before analysis.
#' @param ci_type Type of bootstrap confidence interval: `"perc"` (percentile) or `"bca"`
#'   (bias-corrected and accelerated, the default), passed to [boot::boot.ci()].
#' @return A tibble with one row per parameter (slope, intercept) giving the point estimate and its confidence interval.
#' @export
olp <- function(
  data,
  reference,
  comparison,
  conf = 0.95,
  R = 2000,
  na_rm = TRUE,
  ci_type = "bca"
) {
  df <- tidyr::tibble(
    y = data[[reference]],
    x = data[[comparison]]
  )

  if (na_rm) {
    df <- tidyr::drop_na(df)
  }

  ci_type <- match.arg(ci_type, c("perc", "bca"))
  # boot.ci names its result component "percent" for type = "perc"
  ci_component <- switch(ci_type, perc = "percent", bca = "bca")

  stat <- function(d, i) {
    x <- d$x[i]
    y <- d$y[i]
    slope <- sd(y) / sd(x)
    intercept <- mean(y) - slope * mean(x)
    c(slope = slope, intercept = intercept)
  }

  boot_out <- boot::boot(df, statistic = stat, R = R)

  purrr::map(seq_along(boot_out$t0), \(i) {
    b <- boot::boot.ci(boot_out, type = ci_type, conf = conf, index = i)[[ci_component]][4:5]
    tidyr::tibble(
      parameter = names(boot_out$t0)[[i]],
      estimate = unname(boot_out$t0)[[i]],
      lower_ci = b[1],
      upper_ci = b[2]
    )
  }) |>
    purrr::list_rbind()
}
