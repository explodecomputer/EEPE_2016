###########
## INTRO ##
###########


# This is an R script
# It is just a plain text file, and it has a ".R" suffix so that humans know that it is R code insde
# In R Studio you can tell R to evaluate a line by simply putting the cursor on the line and pressing ctrl+enter (or cmd+enter if you are on a mac)
# Any line that begins with a '#' is ignored - this is known as a 'comment', not a piece of code
# But any other line will be executed. For example, execute the following sum:

1 + 1



##################
## READING DATA ##
##################


# We will play around with some data
# Read in the phenotype data that we're going to be using for the practicals

phen <- read.table("data/genetic/phen.txt", header=TRUE, stringsAsFactors=FALSE)


# What does the data look like?

dim(phen)
head(phen)


# What kind of data is 'phen'

class(phen)


# Data frames are tables, each column can be a different type of data.

# Let's look at diastolic blood pressure (DBP)
# We can extract just the DBP column like this:

phen$DBP


# This prints a lot of stuff to the console, we can use the 'head' function to avoid this:

head(phen$DBP)


# What kind of data is this column?

class(phen$DBP)


# What kind of data is the FID column?

class(phen$FID)


# So we see that there are different data types in the 'phen' data.frame

# What does the DBP data look like?
summary(phen$DBP)


# Let's plot the data
plot(phen$DBP)

# This is just plotting the values in the order that it finds them
# More useful might be a histogram

hist(phen$DBP)

# We can get finer resolution

hist(phen$DBP, breaks=100)

# What is the mean value of phen$DBP?

mean(phen$DBP)

# What is the standard deviation?

sd(phen$DBP)



# What is the median and the mode?
# Write the code here.



# Is this normally distributed?
# Let's compare it to the expected normal distribution curve for the same mean and standard deviation

hist(phen$DBP, prob=TRUE, density=20, main="Histogram of DBP and expected normal curve", xlab="DBP")
curve(
	dnorm(x, mean=mean(phen$DBP), sd=sd(phen$DBP)),
	col="darkblue",
	lwd=2,
	add=TRUE,
	yaxt="n"
)


# Make the same plot, but for BMI
# Write the code here.




#####################
## STANDARD ERRORS ##
#####################


# The standard error of the mean can be calculated like this:
# The standard deviation divided by the sqrt of the sample size
sd(phen$DBP) / sqrt(length(phen$DBP))


# We could use R to calculate an empirical standard error

# 1. Sample with replacement the same number of individuals from the data
# 2. Record the mean
# 3. Repeat

# To sample values with replacement, we can use the sample command, for example here is a vector of 1 to 10

1:10

# Now we sample it with replacement:

sample(1:10, replace=TRUE)

# See that sometimes the same number has occurred more than once
# We can do the same using the DBP phenotype

# What happens if we estimate the mean using just 10 individuals
# Get 10 individuals chosen at random, WITH replacement
DBP_sample <- sample(phen$DBP, replace=TRUE)
hist(DBP_sample)

# Notice the mean is slightly different from the original values
mean(DBP_sample)
mean(phen$DBP)

# Let's do this 10000 times

nsample <- 10000
sample_means <- array(0, nsample)
for(i in 1:nsample)
{
	message(i)
	DBP_sample <- sample(phen$DBP, replace=TRUE)
	sample_means[i] <- mean(DBP_sample)
}

# What do our sampled means look like? Plot a histogram of all the sample means
hist(sample_means)

# Compare the standard deviation of the sample means to the standard error
sd(sample_means)
sd(phen$DBP) / sqrt(length(phen$DBP))

# Quite close...
# The standard error of the mean relates to what would happen if we did the same experiment lots of times
# This is the logic behind 'frequentist' statistics



#############
## T tests ##
#############



# Is the mean value of BMI different between people with and without hypertension?

# Let's look at the hypertension variable

summary(phen$HT)
table(phen$HT)

# How does BMI differ between cases and controls?
# Let's make a boxplot

boxplot(BMI ~ HT, phen)

# Looks like we have an outlier in BMI.
# Let's remove outliers using the rule:
# If a value is +/- 5 standard deviations from the mean then remove it

index1 <- phen$BMI > mean(phen$BMI) + 5 * sd(phen$BMI)
index2 <- phen$BMI < mean(phen$BMI) - 5 * sd(phen$BMI)

# How many outliers do we have?
table(index1)
table(index2)

# Remove anyone who is in index1 or index2
phen$BMI[index1 | index2] <- NA


# Let's calculate the mean of BMI
mean(phen$BMI)

# Problem: There are now missing values in the data. To account for this:
mean(phen$BMI, na.rm=TRUE)

# What does the BMI distribution look like?
hist(phen$BMI, prob=TRUE, density=20, breaks=100, main="Histogram of BMI and expected normal curve", xlab="BMI")
curve(
	dnorm(x, mean=mean(phen$BMI, na.rm=TRUE), sd=sd(phen$BMI, na.rm=TRUE)),
	col="darkblue",
	lwd=2,
	add=TRUE,
	yaxt="n"
)

# There is some slight skewness to the data. But it's not too bad
# You can tell this is simulated data because you wouldn't expect to see BMI values below 10!

# Let's look at the boxplot again
boxplot(BMI ~ HT, phen)

# This part
# BMI ~ HT
# Is known as a 'formula' in R. It says that BMI is a response of HT. 
# In terms of the boxplot, it makes a different box for each value of HT.

# It looks like there is a difference in means. How much precision is there in these estimates?

# Calculate the mean and standard error of the BMI amongst individuals without HT

m1 <- mean(phen$BMI[phen$HT == 1], na.rm=TRUE)
se1 <- sd(phen$BMI[phen$HT == 1], na.rm=TRUE) / sqrt(sum(phen$HT == 1 & !is.na(phen$BMI)))


# Do the same for individuals who do have HT
# Write the code here

m2 <- mean(phen$BMI[phen$HT == 2], na.rm=TRUE)
se2 <- sd(phen$BMI[phen$HT == 2], na.rm=TRUE) / sqrt(sum(phen$HT == 2 & !is.na(phen$BMI)))


# A T test can be conducted with this information
# Calculate the T value:
t_value <- abs(m1 - m2) / sqrt(se1^2 + se2^2)

# Get the P-value from the T value:
pt(t_value, df=nrow(phen), lower.tail=FALSE)

# Note - the precise DF is actually a more complicated formula. Just using sample size for simplicity

# A quicker way is to use R's built in t.test function
t.test(phen$BMI[phen$HT == 1], phen$BMI[phen$HT == 2])



#######################
## Linear regression ##
#######################



# Let's look at the C-reactive protein (CRP) measures

hist(phen$CRP, breaks=100)

# This is heavily skewed. And it looks like there are some outliers.
# Let's log transform the variable


phen$logCRP <- log(phen$CRP)
hist(phen$logCRP)

# This looks much better. Let's remove any outliers as we did last time:

index1 <- phen$logCRP > mean(phen$logCRP) + 3 * sd(phen$logCRP)
index2 <- phen$logCRP < mean(phen$logCRP) - 3 * sd(phen$logCRP)
phen$logCRP[index1 | index2] <- NA


# How many outliers were there?

table(is.na(phen$logCRP))


# Let's plot this distribution
hist(phen$logCRP, prob=TRUE, density=20, breaks=100, main="Histogram of logCRP and expected normal curve", xlab="logCRP")
curve(
	dnorm(x, mean=mean(phen$logCRP, na.rm=TRUE), sd=sd(phen$logCRP, na.rm=TRUE)),
	col="darkblue",
	lwd=2,
	add=TRUE,
	yaxt="n"
)


# We've been using this same bit of code a lot
# To be more efficient in future, we should use functions

plot_distribution <- function(y, main_title="Histogram and expected normal curve", x_title="Values")
{
	hist(y, prob=TRUE, density=20, breaks=100, main=main_title, xlab=x_title)
	curve(
		dnorm(x, mean=mean(y, na.rm=TRUE), sd=sd(y, na.rm=TRUE)),
		col="darkblue",
		lwd=2,
		add=TRUE,
		yaxt="n"
	)
}

plot_distribution(phen$logCRP, main_title="logCRP")

# Here we have defined our own function called plot_distribution
# We can now pass any vector of values to it and it will do the same operation

plot_distribution(phen$BMI, main_title="BMI")
plot_distribution(phen$DBP, main_title="DBP")


# Is CRP associated with BMI?

plot(BMI ~ logCRP, phen)

# It looks like there is a positive relationship, let's draw a line of best fit
# The regression line can be calculated using this formula:

slope <- cov(phen$BMI, phen$logCRP, use="pair") / var(phen$logCRP, na.rm=TRUE)
intercept <- mean(phen$BMI, na.rm=TRUE) - slope * mean(phen$logCRP, na.rm=TRUE)

plot(BMI ~ logCRP, phen)
abline(a = intercept, b = slope, col="darkred", lwd=3)


# Alternatively, we can use R's built in linear regression tools
# This is how to calculate the linear regression:

lm(BMI ~ logCRP, data=phen)

# We can use this to draw the regression line
plot(BMI ~ logCRP, phen, col="grey")
abline(lm(BMI ~ logCRP, phen), col="blue", lwd=3)

# lm is actually quite a powerful tool. It provides diagnostics about the regression
plot(lm(BMI ~ logCRP, phen))
# These are used to interpret how influential a particular point is on the model

# What happens if we want to estimate the effect of CRP but fitting SBP and DBP as covariates?
lm(BMI ~ logCRP + SBP + DBP, phen)

# We can get the standard errors of these estimates

summary(lm(BMI ~ logCRP + SBP + DBP, phen))

# This is the result from a multiple regression.
# You can calculate this directly using matrix operations
# Note - handling missing values requires more complex methods, just setting missing values to 0 for convenience


X <- as.matrix(data.frame(intercept=1, logCRP=phen$logCRP, SBP=phen$SBP, DBP=phen$DBP))
X[is.na(X)] <- 0
y <- as.matrix(phen$BMI)
y[is.na(y)] <- 0

solve(t(X) %*% X, na.rm=TRUE) %*% t(X) %*% y


# What is the power of detecting an effect of this magnitude for different sample sizes?
# How much variance is explained by logCRP on BMI?

sample_sizes <- seq(50, 500, by=50)
variance_explained <- cor(phen$logCRP, phen$BMI, use="pair")^2

pwr <- power.anova.test(n=sample_sizes, groups=2, between.var=variance_explained, within.var=1-variance_explained, sig.level=0.05)

plot(pwr$power ~ pwr$n)



#########################
## Logistic regression ##
#########################



# What is the effect of BMI on hypertension?

# We could do an approximate odds ratio
# Let's dichotomise BMI to be values above the mean or below the mean

phen$BMI_binary <- NA
phen$BMI_binary[phen$BMI >= mean(phen$BMI, na.rm=TRUE)] <- 1
phen$BMI_binary[phen$BMI < mean(phen$BMI, na.rm=TRUE)] <- 0

table(phen$BMI_binary)

# Calculate the odds ratio between hypertension and high/low BMI
tab <- table(phen$HT, phen$BMI_binary)

# Odds of high BMI in a case / odds of low BMI in a case
# Odds of high BMI in a case
ohb <- tab[1,1] / tab[1,2]

# Odds of low BMI in a case
olb <- tab[1,2] / tab[2,2]

odds_ratio <- ohb / olb
olb / ohb

# Big effect...

# What is the effect of an increase in a BMI unit on risk of HT?
# We can use logistic regression to calculate the log of the odds ratio
glm(as.factor(HT) ~ BMI, phen, family="binomial")

# This is a generalised linear model - it uses the logit link function to regress BMI against the binary outcome

# We can obtain standard errors using 'summary'
summary(glm(as.factor(HT) ~ BMI, phen, family="binomial"))

# let's save the coefficients

res <- coefficients(summary(glm(as.factor(HT) ~ BMI, phen, family="binomial")))
res

# The probability of having hypertension for every increase of one unit in BMI:

exp(res[2,1])


# We can visualise how the link function works by plotting it:
# E.g. for HT and DBP
# Let's just use 20 values for clarity

index <- c(which(phen$HT == 1)[1:10], which(phen$HT == 2)[1:10])

plot(I(HT-1) ~ DBP, phen[index,], col="darkblue", ylab="HT", xlim=c(50,110))
mod <- glm(as.factor(HT) ~ DBP, family=binomial, phen, na.action="na.exclude")
curve(predict(mod, data.frame(DBP=x), type="resp"), add=TRUE)
points(phen$DBP[index], fitted(mod)[index], pch=10)
