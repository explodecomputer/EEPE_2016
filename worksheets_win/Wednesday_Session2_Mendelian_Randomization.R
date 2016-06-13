library(sem) #R package needed for two stage least squares analysis

set.seed(999) #Set seed for random number generator

nind <- 100000 #Number of individuals

#Model parameters being simulated
Vq <- 0.02      #Variance of QTL affecting variable X
bzx <- sqrt(Vq) #Path coefficient between SNP and variable X
bxy <- 0        #Causal effect of X on Y
bux <- 0.5      #Confounding effect of U on X
buy <- 0.5      #Confounding effect of U on Y

p <- 0.5             #Decreaser allele frequency
q <- 1-p             #Increaser allele frequency
a <- sqrt(1/(2*p*q)) #Calculate genotypic value for genetic variable of variance one

Vex <- (1- Vq - bux^2)  #Residual variance in variable X (so variance adds up to one)
sdex <- sqrt(Vex)       #Residual standard error in variable X

Vey = 1 - (bxy^2 + 2*bxy*bux*buy + buy^2)  #Residual variance for Y variable (so variance adds up to one)
sdey <- sqrt(Vey)                          #Residual standard error in variable Y

#Simulate individuals
Z <- sample(c(-a,0,a), nind, replace = TRUE, prob = c(p^2, 2*p*q, q^2))          #Simulate genotypic values
U <- rnorm(nind, 0, 1)                                                           #Confounding variables
X <- bzx*Z + bux*U + rnorm(nind, 0, sdex)                                        #X variable
Y <- bxy*X + buy*U + rnorm(nind, 0, sdey)                                        #Y variable

#Replace snp variable with traditional 0, 1, 2 coding
Z <- replace(Z, Z==a, 2)
Z <- replace(Z, Z==0, 1)
Z <- replace(Z, Z==-a, 0)

#Ordinary least squares regression (WARNING CONFOUNDING!!)
summary(lm(Y~X))

#Mendelian randomization analysis
summary(tsls(Y ~ X, ~ Z))

plot(Y,X)
abline(a=0.0009541,b=0.2488429,col="red") #OLS regression
abline(a=0.0009765873,b=0.0007532250, col="green") #IV regression (MR analysis)

