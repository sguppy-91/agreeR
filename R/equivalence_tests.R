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
