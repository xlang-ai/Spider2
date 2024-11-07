# Welch's t-test

From Wikipedia, the free encyclopedia

In statistics, Welch's t-test, or unequal variances t-test, is a two-sample location test which is used to test the (null) hypothesis that two populations have equal means. It is named for its creator, Bernard Lewis Welch, and is an adaptation of Student's t-test, and is more reliable when the two samples have unequal variances and possibly unequal sample sizes. These tests are often referred to as "unpaired" or "independent samples" t-tests, as they are typically applied when the statistical units underlying the two samples being compared are non-overlapping. Given that Welch's t-test has been less popular than Student's t-test and may be less familiar to readers, a more informative name is "Welch's unequal variances t-test" — or "unequal variances t-test" for brevity.

## Assumptions

Student's t-test assumes that the sample means being compared for two populations are normally distributed, and that the populations have equal variances. Welch's t-test is designed for unequal population variances, but the assumption of normality is maintained. Welch's t-test is an approximate solution to the Behrens–Fisher problem.

## Calculations

Welch's t-test defines the statistic t by the following formula:

$$t=\frac{\triangle\overline{X}}{s_{\triangle\overline{X}}}=\frac{\overline{X}_1-\overline{X}_2}{\sqrt{s^2_{\overline{X}_1}+s^2_{\overline{X}_2}}}$$
$$s_{\overline{X}_i}=\frac{s_i}{\sqrt{N_i}}$$

where $\overline{X}_i$ and $s_{\overline{X}_i}$ are the $i$-th sample mean and its standard error, with $s_i$ denoting the corrected sample standard deviation, and sample size $N_i$. Unlike in Student's t-test, the denominator is not based on a pooled variance estimate.

The degrees of freedom $\nu$ associated with this variance estimate is approximated using the Welch–Satterthwaite equation:

$$\nu\approx\frac{(\frac{s^2_1}{N_1}+\frac{s^2_2}{N_2})^2}{\frac{s^4_1}{N^2_1\nu_1}+\frac{s^4_2}{N^2_2\nu_2}}$$

This expression can be simplified when $N_1=N_2$:
$$\nu\approx\frac{s^4_{\triangle\overline{X}}}{\nu^{-1}_1s^4_{\overline{X}_1}+\nu^{-1}_2s^4_{\overline{X}_2}}$$

Here, $\nu _{i}=N_{i}-1$ is the degrees of freedom associated with the $i$-th variance estimate.

The statistic is approximately from the t-distribution since we have an approximation of the chi-square distribution. This approximation is better done when both $N_{1}$ and $N_2$ are larger than 5.


## Example

The t-score, assuming the distributions of gene expression with and without mutation have unequal variances, is computed by using the following equation:

$$t=\frac{g_y-g_n}{\sqrt{\frac{s^2_y}{N_y}+\frac{s^2_n}{N_n}}}$$

where
- $g_y$ and $g_n$ are mean gene expression of participants with and without mutation;
- $N_y$ and $N_n$ are the number of participants in the group with and without mutation;
- $s^2_y$ and $s^2_n$ are the variance of gene expression for the participants with and without mutation, respectively.
Since the Somatic mutation table contains information of positive somatic mutation only, the averages and variances needed to compute the t-score are computed as a function $S_y=\sum_{i=1}^{N_y}g_i$ and $Q_y=\sum_{i=1}^{N_y}g^2_i$, the sums over the gene expression and squared gene expression for articipants with somatic mutation.

After computing $S_y$ and $Q_y$, we can compute the mean and the variance as:

$$g_y=\frac{S_y}{N_y}$$
$$s^2_y=\frac{1}{N_y-1}[Q_y-\frac{S^2_y}{N_y}]$$

To compute $S_n$ and $Q_n$, we first compute the sums of the gene expression and squeared gene expression using all the samples and then substract $S_y$ and $Q_y$. The following query uses this approach to compute the necessary variances and means, and then computes t-score. The t-score is only computed if the variances are greater than zero and if the number of participants in each group is greater than a user defined threshold (e.g., 10).


## Statistical test

Once $t$ and $\nu$ have been computed, these statistics can be used with the t-distribution to test one of two possible null hypotheses:

- that the two population means are equal, in which a two-tailed test is applied; or
- that one of the population means is greater than or equal to the other, in which a one-tailed test is applied.

The approximate degrees of freedom are real numbers $\nu \in \mathbb {R} ^{+}$ and used as such in statistics-oriented software, whereas they are rounded down to the nearest integer in spreadsheets.

## Advantages and limitations

Welch's t-test is more robust than Student's t-test and maintains type I error rates close to nominal for unequal variances and for unequal sample sizes under normality. Furthermore, the power of Welch's t-test comes close to that of Student's t-test, even when the population variances are equal and sample sizes are balanced. Welch's t-test can be generalized to more than 2-samples, which is more robust than one-way analysis of variance (ANOVA).

It is not recommended to pre-test for equal variances and then choose between Student's t-test or Welch's t-test. Rather, Welch's t-test can be applied directly and without any substantial disadvantages to Student's t-test as noted above. Welch's t-test remains robust for skewed distributions and large sample sizes. Reliability decreases for skewed distributions and smaller samples, where one could possibly perform Welch's t-test