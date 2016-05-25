# Set the work directory to the results/greml folder

setwd("EEPE/results/greml") # Your path might look different


readGRM <- function(rootname)
{
	bin.file.name <- paste(rootname, ".grm.bin", sep="")
	n.file.name <- paste(rootname, ".grm.N.bin", sep="")
	id.file.name <- paste(rootname, ".grm.id", sep="")

	cat("Reading IDs\n")
	id <- read.table(id.file.name)
	n <- dim(id)[1]
	cat("Reading GRM\n")
	bin.file <- file(bin.file.name, "rb")
	grm <- readBin(bin.file, n=n*(n+1)/2, what=numeric(0), size=4)
	close(bin.file)
	cat("Reading N\n")
	n.file <- file(n.file.name, "rb")
	N <- readBin(n.file, n=n*(n+1)/2, what=numeric(0), size=4)
	close(n.file)

	cat("Creating data frame\n")
	l <- list()
	for(i in 1:n)
	{
		l[[i]] <- 1:i
	}
	col1 <- rep(1:n, 1:n)
	col2 <- unlist(l)
	grm <- data.frame(id1=col1, id2=col2, N=N, grm=grm)	

	ret <- list()
	ret$grm <- grm
	ret$id <- id
	return(ret)
}


geno <- readGRM("../../data/kinships/precomputed/geno_qc")


# What does the matrix look like?
head(geno$grm, 20)

# Note that the GRM is a square matrix which is symmetrical along the diagonal
# Note that the GRM data is stored here in "long" format - each row corresponds to a pair of individuals
# Note that when id1 equals id2 (ie. the relationship of a person with themself) the value is close to 1
# these form the diagonal elements of the matrix

# How many samples?
dim(geno$id)

# We expect the number of rows in the GRM to be the size of a lower triangular NxN matrix
nrow(geno$id) * (nrow(geno$id) + 1) / 2

# Does this correspond to the size of the GRM file?
dim(geno$grm)

# Plot the distribution of diagonal elements in the GRM
pdf("grm_diags.pdf")
hist(subset(geno$grm, id1 == id2)$grm, breaks=100, xlab="Diagonal elements of GRM", main="")
dev.off()


# Plot the distribution of off-diagonals elements in the GRM
# These are the relationships of all pairs of individuals (not with themselves)
# Only plotting the first 100000 pairs of individuals in the interests of time!
pdf("grm_offdiags.pdf")
hist(subset(geno$grm, id1 != id2)$grm[1:100000], breaks=100, xlab="Diagonal elements of GRM", main="")
dev.off()

