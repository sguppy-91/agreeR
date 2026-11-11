set.seed(123)
n <- 40
a <- rnorm(n, 50, 5)
b <- a + rnorm(n, 0, 1)
dat <- data.frame(a = a, b = b)

test_that("equiv_test declares equivalence when the CI lies within the bounds", {
  res <- equiv_test(dat, reference = "a", comparison = "b", lower = -1, upper = 1, R = 500)

  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1L)
  expect_equal(res$metric, "Mean difference")
  expect_equal(res$estimate, mean(a - b))
  expect_true(res$equivalent)
})

test_that("equiv_test does not declare equivalence for tight bounds", {
  res <- equiv_test(dat, reference = "a", comparison = "b", lower = -0.001, upper = 0.001, R = 500)
  expect_false(res$equivalent)
})

test_that("equiv_test supports percentile bootstrap intervals", {
  res <- equiv_test(
    dat, reference = "a", comparison = "b",
    lower = -1, upper = 1, R = 500, ci_type = "perc"
  )
  expect_true(res$lower_ci < res$upper_ci)
})

test_that("equiv_test validates bounds and ci_type", {
  expect_error(
    equiv_test(dat, reference = "a", comparison = "b", lower = 1, upper = -1),
    "lower must be less than upper"
  )
  expect_error(
    equiv_test(dat, reference = "a", comparison = "b", lower = -1, upper = 1, ci_type = "bogus")
  )
})
