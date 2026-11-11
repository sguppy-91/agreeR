# agreeR (development version)

# agreeR 0.1.0

* Initial public release.
* `ba_loa()`: Bland-Altman mean bias and 95% limits of agreement with bootstrap confidence intervals (`boot`).
* `olp()`: ordinary least products regression slope and intercept (Ludbrook, 2012) with bootstrap confidence intervals.
* `equiv_test()`: two one-sided tests (TOST) equivalence test for the mean difference, using a bootstrap confidence interval.
* Bootstrap confidence intervals can be percentile (`ci_type = "perc"`) or bias-corrected and accelerated (`ci_type = "bca"`, the default).
