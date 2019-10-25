
############################### llfit() ################

# arguments

#   data: either an R table or a data frame; in latter case, last column is
#      frequencies, required name 'Freq' -- will be generated if missing
#   degree: maximum interaction degree, e.g. 2 for interactions 
#      between pairs of variables

llFit <- function(data, degree)
{
   if(class(data) == "table") dFrame <- as.data.frame(data)	
   else {
      if (names(data)[ncol(data)] != 'Freq') {
         tmp <- table(data)
         data <- as.data.frame(tmp)
      }
      dFrame <- data	
   }
   
   if (nrow(dFrame) > sum(dFrame[,ncol(dFrame)]))
      stop("number of categories in the table greater than number of rows in the original data")   
   ncol <- ncol(dFrame) - 1  
   if(degree > ncol)
      stop("degree greater than number of variables", call. = FALSE)
   var_x <- colnames(dFrame)[1:ncol]
   var_y <- colnames(dFrame)[ncol + 1]
   if(degree == 1) {
      rh_formula <- paste(var_x, collapse = " + ")
      est <- fitGLM(rh_formula,dFrame,var_y)
      betas <- est$coef
      variance <- diag(vcov(est))
      beta_var <- list("beta" = betas, "var" = variance)
      return(beta_var)
   } else {
      formula_list = list()
      for(i in 1:degree)
         {
         product <- combn(colnames(dFrame)[1:ncol], i,
                    FUN = paste0, collapse = "*" ,  simplify = FALSE)
         sum_pro <- paste(product, collapse = " + ")
         formula_list[[i]] <- sum_pro
         }
      rh_formula <- paste(formula_list, collapse = " + ")
      est <- fitGLM(rh_formula,dFrame,var_y)
      betas <- est$coef
      se <- sqrt(diag(vcov(est)))
      betase <- data.frame("beta" = betas, "se" = se)
      list(betase=betase, glmout=est)
   }
}

fitGLM <- function(rh_formula,dFrame,var_y) {
      formula_string <- paste(var_y, rh_formula, sep = " ~ ")
      formula <- as.formula(formula_string)
      glm(formula, data=dFrame, family=poisson)
}

# explore the betas, one factor at a time; llFit is output of
# cat_pred_auto()

exploreBetas <- function(llFitOut) 
{
   fit <- llFitOut$betase
   # find primary factors
   rn <- row.names(fit)
   coln <- grep(':',rn)
   pfs <- rn[-coln]
   pfs <- pfs[-1]  # don't consider the intercept a primary factor
   
   for (pf in pfs) {
      rws <- grep(pf,rn)
      print(fit[c(1,rws),])
      readline('hit Enter for next primary factor')
   }
}


## Example 
### ucb <- UCBAdmissions
### ucbdf <- as.data.frame(ucb)
### test1 <- cat_pred_auto(ucb, 2, type="tb"); summary(test1)
### test2 <- cat_pred_auto(ucbdf, 2); test2

## ################ cat_pred_self() ################
## 
## ## inputs new dataframe
## 
## ## inputs function of polynomial as string
## 
## ## input data type, default type="df"
## 
## cat_pred_self <- function(data, rh_formula, type = "df")
## {
##    if(type == "tb")
##       {
##       df <- as.data.frame(data)	
##       }
##    else
##       {
##       df <- data	
##       }
##    ncol <- ncol(df)
##    var_y <- colnames(df)[ncol]
##    formula_string <- paste(var_y, rh_formula, sep = " ~ ")
##    formula <- as.formula(formula_string)
##    est <- glm(formula, data=df, family="poisson")
##    betas <- est$coef
##    variance <- diag(vcov(est))
##    beta_var <- list("beta" = betas, "var" = variance)
##    return(beta_var)
## }

## Example code
### form <- "persfin + natecon + persfin*natecon"
### result2 <- cat_pred_self(newdata, form)
