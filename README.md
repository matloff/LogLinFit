
# LogLinFit

(Under construction.)

Formulation of parsimonious models for contingency tables.

## Package goal

Note that the goal is NOT to fit the "best" model, in the sense of
optimal estimates.  As the sample size goes to infinity, the optimal
model will be the full model, with interactions through degree k for k
factors.  

Instead, our goal is a *parsimonious* model, i.e. we wish to capture
most of the variation but retain simplicity.  This goal is motivated as
follows:

* Models with interactions of degree higher than 3 are difficult to
  interpret, especially if the number of factors is large.

* In many applications, the contingency table is not the end product.
  Instead, the factors are used as predictor variables in regression or
classification settings.  A parsimonious model helps avoid overfitting
in the regression/classification settings.


Clearly there are many possible interactions among those categorical
variables (also between the categorical and continuous variables, but we
do not address that).  The question of interest is, Which interactions
should be included as Xs in our regressing Y against the Xs?  Including
too many interactions might be unwieldy and difficult to interpret,
and cause overfitting.

Continuous variables might be age of entry to the program and
undergraduate GPA.  Categorical variables might be graduate field of
study, undergraduate field of study, gender and a variable indicating
whether the student had undergraduate research experience.

The purpose of this package, then, is to choose a set of interactions 
between categorical variables, for use as inputs for predictive
regression models, using selection methods other than significance testing.

## Moving away from testing 

R has several functions/packages for building log-linear models.
However, most are significance-testing oriented.  There has long
been concern among statisticians regarding testing, and the 
[recent ASA position paper](https://amstat.tandfonline.com/doi/full/10.1080/00031305.2016.1154108#.XWoK5fxlA5k)
advises great caution in using such methodology.

In deriving model-selection procedures that don't use testing, we may
need standard errors for the model coefficients.  Yet for instance the
function **stat::loglin()** only outputs point estimates (and even then,
only on request), not standard errors.  Fortunately, obtaining standard
errors is easy, by employing the "Poisson trick":  Instead of assuming
that the cell counts follow a multinomial distribution, it can be shown
that the same likelihood equations follow from assuming that the counts
are independent and Poisson-distributed.  This allows the problem to
approached using Poisson regression in **glm()**.

## First ad hoc method

Thus one very informal method would be to simply fit a model with
interaction terms up to a desired degree, then visually decide which
interactions to keep and which to discard.

### Example:  UCB admissions data

Consider the **UCBAdmissions** dataset that is part of base-R.  Let's
fit a model with interactions through degree 2.  (We don't have a Y
variable here, just an example of fitting.)

``` r
> llout <- cat_pred_auto(UCBAdmissions,2)
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

With only three primary factors, this function is less useful here, but
with more factors, or a higher-degree model, it can be a very useful
tool.

## Example:  prgeng data


