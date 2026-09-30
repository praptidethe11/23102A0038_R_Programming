#Week 10: Strings - Substitution and Replacement, Data Frames

#SUBSTITUTION AND REPLACEMENT OF STRINGS

#sub replaces the first instance of a substring, gsub replaces all instances (global replace)
#Usage: sub(old, new, string)
#Usage: gsub(old, new, string)

y = "Number of participants: 25"
sub("25", "30", y)

#sub replaces only the first match
y = "Mr. Singh is the smart one. Mr. Singh is funny, too."
y
sub("Mr. Singh", "Professor Jha", y)

#gsub replaces all matches
gsub("Mr. Singh", "Professor Jha", y)

#compare sub and gsub
gsub("Mr. Singh", "Professor Jha", y)
sub("Mr. Singh", "Professor Jha", y)

#a partial match is not replaced, since "Mr. Singh" must match fully
y = "Mr. Singh is the smart one. Mr. is funny, too."
gsub("Mr. Singh", "Professor Jha", y)

#SEARCHING WITH GREP

#R has various functions for regular expression based matching and replacement
#grep, grepl are used for searching matches, sub and gsub are used for replacement
#grep : Globally search regular expression and print it
#Usage: grep(pattern, x, ignore.case = FALSE, value = FALSE)

#value = TRUE returns the matching elements themselves
str = c("R Course", "exercises", "include examples of R language")
grep("ex", str, value = TRUE)

#value = FALSE (default) returns the indices of the matching elements
grep("ex", str, value = FALSE)

#ignore.case - FALSE is case sensitive, TRUE ignores case
str = c("R Course", "exercises", "include examples of r language", "in R software.")
grep("R", str, ignore.case = FALSE, value = TRUE)
grep("R", str, ignore.case = TRUE, value = TRUE)

#indices with and without ignoring case
grep("R", str, ignore.case = TRUE, value = FALSE)
grep("R", str, ignore.case = FALSE, value = FALSE)

#grep on a combined vector of strings
x = "R course 24.07.2022"
y = "Number of participants: 25"
c(x, y)  #Combine the two strings
grep("our", c(x, y))  #"our" is in the 1st element (in the word course), not in y
grep("Num", c(x, y))  #"Num" is in the 2nd element (in the word Number), not in x

#GREPL FUNCTION

#grepl returns TRUE or FALSE for each element, indicating if the match is available
#Usage: grepl(pattern, x)
str = c("R Course", "exercises", "include examples of R language")
str
grepl("R", str)
grepl("ex", str)

#grepl has no value argument, grepl("ex", str, value = TRUE) gives an unused argument error

#DATA FRAMES

#c, cbind, vector and matrix combine data, another option is the data frame
#a data frame combines variables of equal length, each row is an observation on the same unit
#it can hold numeric variables, character strings and factors together
#cbind and matrix cannot combine different types of data
#format is similar to a spreadsheet: columns are variables, rows are observations

#example data frame painters is available in the library MASS
library(MASS)
painters

#names of the painters serve as row identification
rownames(painters)

#column names
colnames(painters)

#extracting a variable (column) with the dollar sign operator
is.numeric(painters$School)
is.numeric(painters$Drawing)

is.factor(painters$School)
is.factor(painters$Drawing)

#summary gives a quick overview of descriptive measures for each variable
#for the factor School, only the 6 most frequent categories are shown, rest are under (Other)
summary(painters)

#summary of a categorical variable returns a frequency table
summary(painters$School)

#ATTACH AND DETACH

#attach lets us use variable names directly, without painters$
attach(painters)
summary(School)       #Character variable
summary(Composition)  #Numeric variable

#detach recovers the default setting, then painters$ has to be used again
detach(painters)
#summary(School)  #Error: object 'School' not found
summary(painters$School)

#SUBSETS OF A DATA FRAME

#subset() with a condition on a factor
subset(painters, School == "F")  #== is the logical equal sign

#equivalent command using indexing
painters[painters[["School"]] == "F", ]

#subset with a numeric condition
subset(painters, Composition <= 6)

#eliminating uninteresting columns with select
subset(painters, School == "F", select = c(-3, -5))  #Colour and School are not shown

#SPLIT

#split partitions the data set by values of a variable (preferably a factor)
splitted = split(painters, painters$School)
splitted

#access one partition
splitted$A
splitted$H

#each partition is itself a data frame
is.data.frame(splitted$A)

#COMBINING DATA FRAMES

#three main techniques
#cbind() - combines columns of two data frames side by side
#merge() - joins two data frames using a common column
#rbind() - stacks two data frames on top of each other

#CBIND

df1 = data.frame(state = c("UP", "MP", "AP", "JK"),
                 popnsize = c(1000, 2000, 3000, 4000))
df2 = data.frame(state = c("UP", "MP", "AP", "JK"),
                 samplesize = c(100, 200, 300, 400),
                 surveycompleted = c("Yes", "No", "Yes", "No"))
df1
df2

#state appears twice in the result
cbind(df1, df2)

#MERGE

#merge joins on common columns or row names
#Usage: merge(x, y, by, by.x, by.y, sort = TRUE, no.dups = TRUE, ...)

#state is common between the two data frames, so merge with respect to state
merge(df1, df2, by = "state")  #result is sorted by state

#RBIND

df11 = data.frame(state = c("UP", "MP", "AP", "JK"),
                  popnsize = c(1000, 2000, 3000, 4000))
df22 = data.frame(state = c("Bihar", "Delhi", "Punjab"),
                  popnsize = c(100, 200, 300))
df11
df22

#column names must match for rbind
rbind(df11, df22)