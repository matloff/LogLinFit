
# LogLinFit

Log linear model via the "Poisson Trick". Non-testing approach to model
selection/dimension reduction.  Package goal:  Given a set of
categorical variables that we wish to use in predicting/classifying
another variable Y, determine a parsimonious model for the interactions
among these variables, for use as X in predicting Y.  (There may also be
continuous predictors.)

## Overview

R has several functions/packages for building log-linear models.
However, they are all significance-testing oriented.  There has long
been concern among statisticians regarding testing, and the recent ASA
position paper advises great caution in using such methodology.

Yet for instance the function **stat::loglin()** only outputs point
estimates (and even then, only on request), not standard errors.

Our goal here is to have a procedure for using categorical variables as
"X" variables in parametric regression modeling of some "Y".  Consider
for instance a study of student duration in PhD programs.  Continuous
variables might be age of entry to the program and undergraduate GPA.
Categorical variables might be graduate field of study, undergraduate
field of study, gender and a variable indicating whether the student had
undergraduate research experience.

Clearly there are many possible interactions among those categorical
variables (also between the categorical and continuous variables, but we
do not address that).  The question of interest is, Which interactions
should be included as Xs in our regressing Y against the Xs?  Including
too many interactions might be unwieldy and difficult to interpret,
and cause overfitting.

The purpose of this package, then, is to choose a set of interactions 
between categorical variables, for use as inputs for regression models,
using selection methods other than significance testing.

Many non-testing methods will require access to standard errors of the
estimated log-linear coefficients.  Fortunately, this is easy, by
employing the "Poisson trick":  Instead of assuming that the cell counts
follow a multinomial distribution, one assumes that they are independent
and Poisson-distributed.  This allows the problem to approached using
Poisson regression in **glm()**.


