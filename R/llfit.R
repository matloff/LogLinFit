

# example; UCBAdmissions dataset, built-in to R

# ucb <- UCBAdmissions
# LLout <- llfit(ucb,2)
# summary(LLout)


############################### llfit() ################

# arguments

#   data: either an R table or a data frame; in the latter case, each
#      column must be a factor
#   degree: maximum interaction degree, e.g. 2 for interactions 
#      between pairs of variables

llFit <- function(dataIn, degree)
{

   if(is.data.frame(dataIn)) dataIn <- table(dataIn)

   if(class(dataIn) == "table") dFrame <- as.data.frame(dataIn)	
   else {
      if (names(dataIn)[ncol(dataIn)] != 'Freq') {
         tmp <- table(dataIn)
         dataIn <- as.data.frame(tmp)
      }
      dFrame <- dataIn
   }
      
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
      ary <- array(fitted(est),dim=dim(dataIn),dimnames=attr(dataIn,'dimnames'))
      rslt <- list(betase=betase, glmout=est, ary=ary)
      class(rslt) <- 'PoissonLogLin'
      rslt
   }
}

fitGLM <- function(rh_formula,dFrame,var_y) {
      formula_string <- paste(var_y, rh_formula, sep = " ~ ")
      formula <- as.formula(formula_string)
      glm(formula, data=dFrame, family=poisson)
}

predict.PoissonLogLin <- function(obj,newdata) 
{
   predict(obj$glmout,newdata,type='response')
}

# generics
coef.PoissonLogLin <- function(x) coef(x$glmout)
summary.PoissonLogLin <- function(x) summary(x$glmout)
vcov.PoissonLogLin <- function(x) vcov(x$glmout)
fitted.PoissonLogLin <- function(x) fitted(x$glmout)

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

