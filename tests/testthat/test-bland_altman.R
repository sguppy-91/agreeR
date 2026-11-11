set.seed(123)
n <- 40
a <- rnorm(n, 50, 5)
b <- a + rnorm(n, 1, 1)
dat <- data.frame(a = a, b = b)

test_that("ba_loa returns mean bias and limits of agreement", {
  res <- ba_loa(dat, reference = "a", comparison = "b", R = 500)

  expect_s3_class(res, "tbl_df")
  expect_equal(res$metric, c("Mean bias", "Lower LoA", "Upper LoA"))

  diff <- a - b
  expect_equal(res$estimate[1], mean(diff))
  expect_equal(res$estimate[2], mean(diff) - 1.96 * sd(diff))
  expect_equal(res$estimate[3], mean(diff) + 1.96 * sd(diff))
  expect_true(all(res$lower_ci < res$upper_ci))
})

test_that("ba_loa supports percentile bootstrap intervals", {
  res <- ba_loa(dat, reference = "a", comparison = "b", R = 500, ci_type = "perc")
  expect_equal(nrow(res), 3L)
  expect_true(all(res$lower_ci < res$upper_ci))
})

test_that("ba_loa drops missing values when na_rm = TRUE", {
  dat_na <- dat
  dat_na$a[1] <- NA
  res <- ba_loa(dat_na, reference = "a", comparison = "b", R = 500)
  expect_equal(res$estimate[1], mean(dat_na$a - dat_na$b, na.rm = TRUE))
})

test_that("ba_loa rejects an invalid ci_type", {
  expect_error(ba_loa(dat, reference = "a", comparison = "b", ci_type = "bogus"))
})
