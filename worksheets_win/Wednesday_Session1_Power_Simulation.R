
set.seed(9999) #Set seed for random number generator

nind <- 2000 #Number of individuals
nrep <- 1000
pval <- vector(length = nrep) #Vector for storing p values

#Model parameters being simulated
Vq <- 0.01      #Variance of QTL affecting variable X
bzx <- sqrt(Vq) #Path coefficient between SNP and variable X (bzx = 0.1)

p <- 0.5             #Decreaser allele frequency
q <- 1-p             #Increaser allele frequency
a <- sqrt(1/(2*p*q)) #Calculate genotypic value for genetic variable of variance one (VA = 2*p*q*a^2)

Vex <- 1- Vq         #Residual variance in variable X (so variance adds up to one)
sdex <- sqrt(Vex)    #Residual standard error in variable X

for (i in 1:nrep) {

#Simulate individuals
Z <- sample(c(-a,0,a), nind, replace = TRUE, prob = c(p^2, 2*p*q, q^2))          #Simulate genotypic values
X <- bzx*Z + rnorm(nind, 0, sdex)                                                #X variable

#Replace snp variable with traditional 0, 1, 2 coding
Z <- replace(Z, Z==a, 2)
Z <- replace(Z, Z==0, 1)
Z <- replace(Z, Z==-a, 0)

#Ordinary least squares regression
regression <- summary(lm(X~Z))
pval[i] <- regression$coefficients[2,4] #Store pvalues

}

length(pval[pval < 0.00000005])/nrep #Empirical power
