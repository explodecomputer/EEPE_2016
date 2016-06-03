## Basic calculations

What is the probability of winning the lottery? Assume 49 balls, and 6 balls chosen without replacement. This is how many unique combinations there are.

$$
\frac{49!}
{6!(49-6)!} 
= 
\frac{49 \times 48 \times 47 \times 46 \times 45 \times 44} {6 \times 5 \times 4 \times 3 \times 2 \times 1}
$$

In R it can be calculated like this:

```{r lottery_manual}
49 * 48 * 47 * 46 * 45 * 44 / (6 * 5 * 4 * 3 * 2 * 1)
```

49 \times 48 \times 47 \times 46 \times 45 \times 44 / (6 \times 5 \times 4 \times 3 \times 2 \times 1)

Or we can use built in functions:

```{r lottery_factorial}
factorial(49) / (factorial(6) * factorial(49-6))
```

We can find out about the `factorial` function like this:

```{r help_factorial}
?factorial
```

We want to store the result from our calculation. This is done like so:

```{r lottery_calculation}
lottery <- factorial(49) / (factorial(6) * factorial(49-6))
```

What happens now if you type 

```{r lottery}
lottery
```

This retrieves the stored value. 

What is the probability of winning the lottery if you buy 1 ticket?

```{r prob_1_ticket}
1 / lottery
```

How about 10 tickets?

```{r prob_10_ticket}
10 / lottery
```

What is the chance of winning the lottery twice?

```{r prob_1_ticket_twice}
(1 / lottery)^2
```

In R we can make vectors of numbers instead of dealing in single elements. For example

```{r make_n}
n <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
```

Here the `c()` command tells R to string the numbers 1 to 10 into an array. Another way to do this is:

```{r make_n_simple}
n <- 1:10
```

Now we can calculate the chances of winning for 1, 2, 3, ..., 10 tickets in one command:

```{r prob_n_ticket}
n / lottery
```

This prints out 10 values, each one is for a different value in `n`.

Notice that we can overwrite a value in a variable, for example

```
n <- 30:40
```

Now type `n` - it has changed because R has replaced the original value with the new value.

It's possible to only extract a single value from an array, using square brackets:

```
n[1]
n[5:8]
```

will extract only the first value of `n` for the first command; or the 5th, 6th, 7th and 8th values in the second command.

How many values are in `n`?

```
length(n)
```

What is the sum of all the values in `n`?

```
sum(n)
```

What is the median value of `n`?

```
median(n)
```

If you type `ls()` you can see your **workspace**. This is the list of all the objects that you have created. Notice that there is one object there called `lottery`, and one called `n`. We can remove objects like this:

```
rm(lottery)
```

Type `ls()` again. Type `lottery`, what happens?


## Data

R comes pre-loaded with some example datasets, one of which we will use here as an example of some basic data manipulation. We will be using the US States Facts and Figures dataset, which is stored as the `state.x77` R object. There is a help file available with background information on this dataset.

The dataset itself is quite large: typing `state.x77` into the R console to look at it results in the output running off the screen.

Instead we can use the `head` function in R to look at the first few rows of the dataset.

```
head(state.x77)
```

or the `tail` function to see the last few rows

```
tail(state.x77)
```

Use the `dim` function to see how many rows and columns it has.

```
dim(state.x77)
```

Type and run the following portion of R code

```
Alaska_Life_Exp <- state.x77[2, 4]
ffrc <- state.x77[1:4, 1:4]
Population <- state.x77[ , 1]
```

This portion of R code uses square brackets to extract data from the `state.x77` R object. Being a table (or matrix) the entries of `state.x77` are indexed by two indices that refer to the row and column. So `state.x77[2, 4]`` gives the entry in the second row and fourth column (the Alaskan life expectancy, 69.05 years). Also s`tate.x77[1:4, 1:4]`` gives the first four rows and columns of the table. Finally, `state.x77[ , 1]`` gives the first column (the population of all the states). Note that the first row displayed in the R console gives the column headings and the first column displayed in the R console gives the row headings. 

Can you use this data to calculate the total area of the US? The total population?


## Plotting

What is the relationship between income and literacy amongst the US states? What is the correlation?

```
cor(state.x77[, "Income"], state.x77[, "Illiteracy"])
```

There seems to be an inverse proportional relationship. We can visualise this:

```
plot(Income ~ Illiteracy, state.x77)
```

What is the distribution of Income?

```
hist(state.x77[, "Income"])
```

You can save a plot like this:

```
pdf("test.pdf")
hist(state.x77[, "Income"])
dev.off()
```


## Reading and writing data

It is important to be able to get data into R, and back out again. Here we will look at two examples - Excel files, and Stata files.


### Excel

In Excel it is possible to save spreadsheet data as `.csv` files - "comma separated values". R can read `.csv` files using the `read.csv()` function. Have a look at the documentation:

```
?read.csv
```

Notice that there are a lot of options here to be as flexible as possible for reading in data that has been formatted in different ways. The default options for `read.csv` are usually suitable for reading in a file that has just been experted from Excel.

Let's try reading in a csv file...

```
phen <- read.csv("../data/example_data/phen.csv")
```

What does this data look like?

```
head(phen)
```

What are the dimensions?

```
dim(phen)
```


### Stata

We can also read in files that are in Stata format. But first we need to install a library that will provide the necessary functions.

```
install.packages("readstata13")
```

Once the library is installed we can load it

```
library(readstata13)
```

And now we can use the functions that are provided by this package. Let's read in a Stata file:

```
phen <- read.dta13("../data/example_data/phen.dta")
```

