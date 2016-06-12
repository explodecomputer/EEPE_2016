rmd2rscript <- function(infile){
	# read the file
	flIn <- readLines(infile)
	# identify the start of code blocks
	cdStrt <- which(grepl(flIn, pattern = "```{r*", perl = TRUE))
	# identify the end of code blocks
	cdEnd <- sapply(cdStrt, function(x){
		preidx <- which(grepl(flIn[-(1:x)], pattern = "```", perl = TRUE))[1]
		return(preidx + x)
	})
	# define an expansion function
	# strip code block indacators
	flIn[c(cdStrt, cdEnd)] <- ""
	expFun <- function(strt, End){
		strt <- strt+1
		End <- End-1
		return(strt:End)
	}
	idx <- unlist(mapply(FUN = expFun, strt = cdStrt, End = cdEnd, 
								SIMPLIFY = FALSE))
	# add comments to all lines except code blocks
	comIdx <- 1:length(flIn)
	comIdx <- comIdx[-idx]
	for(i in comIdx){
		if(flIn[i] != "")
		{
			flIn[i] <- paste("# ", flIn[i], sep = "")
		}
	}
	# create an output file
	nm <- strsplit(infile, split = "\\.")[[1]][1]
	flOut <- file(paste(nm, ".R", sep = ""), "w")
	for(i in 1:length(flIn)){
		cat(flIn[i], "\n", file = flOut, sep = "\t")
	}
	close(flOut)
}

library(rmarkdown)
library(knitr)

rmd2rscript("ewas.rmd")
rmd2rscript("genetic_data.rmd")
rmd2rscript("gwas.rmd")
rmd2rscript("intro_to_r.rmd")
rmd2rscript("basic_stats.rmd")
render("bioinformatics.rmd")
render("ewas.rmd")
render("genetic_data.rmd")
render("gwas.rmd")
render("intro_to_r.rmd")
render("whole_genomes.rmd")
render("basic_stats.rmd")