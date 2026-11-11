set.seed(123)
n <- 40
b <- rnorm(n, 100, 10)
a <- 5 + 0.9 * b + rnorm(n, 0, 3)
dat <- data.frame(a = a, b = b)

test_that("olp slope and intercept match the closed form (Ludbrook 2012, eq. 1)", {
  res <- olp(dat, reference = "a", comparison = "b", R = 500)

  expect_s3_class(res, "tbl_df")
  expect_equal(res$parameter, c("slope", "intercept"))
  expect_equal(res$estimate[1], sd(a) / sd(b))
  expect_equal(res$estimate[2], mean(a) - res$estimate[1] * mean(b))
  expect_true(all(res$lower_ci < res$upper_ci))
})

test_that("olp supports percentile bootstrap intervals", {
  res <- olp(dat, reference = "a", comparison = "b", R = 500, ci_type = "perc")
  expect_equal(nrow(res), 2L)
})

test_that("olp rejects an invalid ci_type", {
  expect_error(olp(dat, reference = "a", comparison = "b", ci_type = "bogus"))
})
