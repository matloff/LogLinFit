library(regtools)

## Example data
ucb <- UCBAdmissions
ucbdf <- as.data.frame(ucb)

################ new_data() ################

## inputs original dataframe

## returns new dataframe

new_data <- function(data)
{
   tbd <- table(data)
   data_new <- as.data.frame(tbd)
   return(data_new)
}

## Newdata = original data + count of each combination
newdata <- new_data(newd)

################ cat_pred_auto() ################

## inputs new data

## inputs degree of polynomial

## input data type, defaul type="df"

cat_pred_auto <- function(data, degree, type = "df")
{
   if(type == "tb")
      {
      df <- as.data.frame(data)	
      }
   else
      {
      df <- data	
      }
   ncol <- ncol(df) - 1
   if(degree > ncol)
      {
      stop("The degree of combination is greater than the number of variables", call. = FALSE)
      }
   else if(degree == 1)
      {
      var_x <- colnames(df)[1:ncol]
      var_y <- colnames(df)[ncol + 1]
      rh_formula <- paste(var_x, collapse = " + ")
      formula_string <- paste(var_y, rh_formula, sep = " ~ ")
      formula <- as.formula(formula_string)
      est <- glm(formula, data=df, family="poisson")
      betas <- est$coef
      variance <- diag(vcov(est))
      beta_var <- list("beta" = betas, "var" = variance)
      return(beta_var)
      }
   else
      {
      var_x <- colnames(df)[1:ncol]
      var_y <- colnames(df)[ncol + 1]
      formula_list = list()
      for(i in 1:degree)
         {
         product <- combn(colnames(df)[1:ncol], i,
                    FUN = paste0, collapse = "*" ,  simplify = FALSE)
         sum_pro <- paste(product, collapse = " + ")
         formula_list[[i]] <- sum_pro
         }
      rh_formula <- paste(formula_list, collapse = " + ")
      formula_string <- paste(var_y, rh_formula, sep = " ~ ")
      formula <- as.formula(formula_string)
      est <- glm(formula, data=df, family="poisson")
      betas <- est$coef
      variance <- diag(vcov(est))
      beta_var <- list("beta" = betas, "var" = variance)
      return(beta_var)
      }
}

## Example code
test1 <- cat_pred_auto(ucb, 2, type="tb"); test1
test2 <- cat_pred_auto(ucbdf, 2); test2

################ cat_pred_self() ################

## inputs new dataframe

## inputs function of polynomial as string

## input data type, defaul type="df"

cat_pred_self <- function(data, rh_formula, type = "df")
{
   if(type == "tb")
      {
      df <- as.data.frame(data)	
      }
   else
      {
      df <- data	
      }
   ncol <- ncol(df)
   var_y <- colnames(df)[ncol]
   formula_string <- paste(var_y, rh_formula, sep = " ~ ")
   formula <- as.formula(formula_string)
   est <- glm(formula, data=df, family="poisson")
   betas <- est$coef
   variance <- diag(vcov(est))
   beta_var <- list("beta" = betas, "var" = variance)
   return(beta_var)
}

## Example code
form <- "persfin + natecon + persfin*natecon"
result2 <- cat_pred_self(newdata, form)

