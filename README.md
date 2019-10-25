
# LogLinFit

(Under construction.)

Formulation of parsimonious models for contingency tables.

## Package goal

Let k denote the number of factors; i.e. we are working with a k-way
table.  A log-linear analysis will produce main effects, 2-way
interactions, 3-way interactions and so on, up through k-way.

A key point is that our goal is NOT to fit the best-fitting model.  In
applications, one seldom if ever has *exact* independence, conditional
independence etc.  So, as the sample size n goes to infinity, the optimal
model will usually be the full model, with interactions all the way
through degree k.  

Instead, our goal is a *parsimonious* model, i.e. we wish to capture
most of the variation but retain simplicity.  This goal is motivated as
follows:

1. Models with interactions of degree higher than 3 are difficult to
  interpret, especially if the number of factors is large.

2. In many applications, the contingency table is not the end product.
   Instead, the factors are used as predictor variables (typically along
with some continuous variables) in regression or classification
settings.  A parsimonious model helps avoid overfitting in these
settings, as well as reducing computation.

The situation is similar to that of Principal Component Analysis, in
both senses (1) and (2) above.  In fact, Principal Component regression
analysis is a
[common technique](http://www.win-vector.com/blog/2016/05/pcr_part1_xonly/).

## Moving away from testing

R has a number of functions/packages for building log-linear models.
However, most are significance-testing oriented.  There has long
been concern among statisticians regarding testing, and the
[recent ASA position paper](https://amstat.tandfonline.com/doi/full/10.1080/00031305.2016.1154108#.XWoK5fxlA5k)
advises great caution in using such methodology.

This point is especially important for our quest for parsimony here.  As
n goes to infinity, all interactions will be "significant," rendering
the analysis irrelevant to formulating a parsimonious model.
Interaction terms will become "significant" even if they are small and
inapproprriate for inclusion in a parsimonious model.

A simlar problem arises with criteria such as Akaike's Information
Criterion, 2c - 2l, where c is the number of cells in the table and l is
the log likelihood.  As n goes to  infinity, l will go to 0, and thus
the maximal AIC will come from maximizing c, i.e. using the full
model.

Confidence intervals are quite useful in such contexts.  In the case of
a significant-but-small interaction term, the interval may not *contain*
0, but it will be *near* 0, showing that we probably don't want it for
our parsimonious model.

## The "Poisson trick"

Thus we need not only point estimates of the interaction terms, but also
their standard errors.  Yet functions in base-R, for instance, do not
provide these.  Indeed, **stat::loglin()** doesn't even output point
estimates unless we request them.

Though some specialized packages do compute standard errors, there is a
simpler solution, employing the "Poisson trick":  Instead of assuming
that the cell counts follow a multinomial distribution, it can be shown
that the same likelihood equations follow from assuming that the counts
are independent and Poisson-distributed.  This allows the problem to
approached using Poisson regression in **glm()**.

## First ad hoc method

Thus one very informal method would be to simply fit a model with
interaction terms up to a desired degree, then visually decide which
interactions to keep and which to discard.

## Caveat

Before conducting *LogLinFit*, users are advised to check whether the number of
the combination of levels of interested variables in the table is greater than
the number of respondents/rows in the original data. *LogLinFit* returns errors
under this situation.

### Example:  UCB admissions data

Consider the **UCBAdmissions** dataset that is part of base-R.  Let's
fit a model with interactions through degree 2, using our package here:  

``` r
> llout <- llFit(UCBAdmissions,2)
> llout
                                  beta         se
(Intercept)                 6.27149855 0.04270539
AdmitRejected              -0.58205140 0.06899258
GenderFemale               -1.99858834 0.10593464
DeptB                      -0.40322049 0.06783513
DeptC                      -1.57790295 0.08949297
DeptD                      -1.35000497 0.08525926
DeptE                      -2.44982025 0.11755415
DeptF                      -3.13787148 0.16173901
AdmitRejected:GenderFemale -0.09987009 0.08084645
AdmitRejected:DeptB         0.04339793 0.10983889
AdmitRejected:DeptC         1.26259802 0.10663286
AdmitRejected:DeptD         1.29460647 0.10582340
AdmitRejected:DeptE         1.73930574 0.12611347
AdmitRejected:DeptF         3.30648006 0.16998179
GenderFemale:DeptB         -1.07482038 0.22861267
GenderFemale:DeptC          2.66513272 0.12609063
GenderFemale:DeptD          1.95832432 0.12733676
GenderFemale:DeptE          2.79518589 0.13925227
GenderFemale:DeptF          2.00231916 0.13571315
```

The point estimate for **AdmitRejected:GenderFemale** is small, say
relative to the intercept term, so we may wish to discard it.  **Note
carefully:** Even if the standard error for this term were tiny, making
the term "highly significant" in classical statistics, we *still* would
probably not want to include it in our model, since the point estimate
is so small.  This is a good example of why the testing approach is not
generally advisable.

We also can view the estimates in groups, based on primary factors:

``` r
> exploreBetas(llout)
                                  beta         se
(Intercept)                 6.27149855 0.04270539
AdmitRejected              -0.58205140 0.06899258
AdmitRejected:GenderFemale -0.09987009 0.08084645
AdmitRejected:DeptB         0.04339793 0.10983889
AdmitRejected:DeptC         1.26259802 0.10663286
AdmitRejected:DeptD         1.29460647 0.10582340
AdmitRejected:DeptE         1.73930574 0.12611347
AdmitRejected:DeptF         3.30648006 0.16998179
hit Enter for next primary factor
                                  beta         se
(Intercept)                 6.27149855 0.04270539
GenderFemale               -1.99858834 0.10593464
AdmitRejected:GenderFemale -0.09987009 0.08084645
GenderFemale:DeptB         -1.07482038 0.22861267
GenderFemale:DeptC          2.66513272 0.12609063
GenderFemale:DeptD          1.95832432 0.12733676
GenderFemale:DeptE          2.79518589 0.13925227
GenderFemale:DeptF          2.00231916 0.13571315
hit Enter for next primary factor
                           beta         se
(Intercept)          6.27149855 0.04270539
DeptB               -0.40322049 0.06783513
AdmitRejected:DeptB  0.04339793 0.10983889
GenderFemale:DeptB  -1.07482038 0.22861267
...
...
...
```

### The Poisson trick does work

By the way, let's confirm that the Poisson trick works.  Here are the
fitted mean cell counts:

``` r
> llout$glmout$fitted.values
         1          2          3          4          5          6          7
529.269919 295.730081  71.730081  36.269919 353.639509 206.360491  16.360491
         8          9         10         11         12         13         14
  8.639509 109.245276 215.754724 212.754724 380.245276 137.207390 279.792610
        15         16         17         18         19         20         21
131.792610 243.207390  45.680810 145.319190 101.319190 291.680810  22.957096
        22         23         24
350.042904  23.042904 317.957096
> loglin(UCBAdmissions, list(c(1, 2), c(1, 3), c(2, 3)),fit=T)$fit
9 iterations: deviation 0.04920393
, , Dept = A

          Gender
Admit            Male     Female
  Admitted 529.272408  71.727459
  Rejected 295.727592  36.272541

, , Dept = B

          Gender
Admit            Male     Female
  Admitted 353.640139  16.359829
  Rejected 206.359861   8.640171
...
...
```

## Example:  prgeng data
